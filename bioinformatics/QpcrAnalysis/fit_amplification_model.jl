#==============================================

    fit_amplification_model.jl

    function to fit amplification models
    this is a refactoring of the function
    previously called mod_bl_q() in amp.jl

    Author: Tom Price
    Date:   July 2019

==============================================#

## constant:
## a value that cannot be obtained by normal calculation of Ct
const AMP_CT_VAL_DOMAINERROR        = -99

#=============================================================================================#


## fit_amplification_model() definition for DFC models
function fit_amplification_model(
    ::Type{Val{M}} where M <: DFCModel,
    ::Type{R},
    i                   ::AmpInput,
    fluos               ::AbstractVector,
    ## these parameters not used to fit DFC models
    baseline_cyc_bounds ::AbstractArray,
    cq_method           ::CqMethod,
    ct_fluo             ::AbstractFloat,
) where R <: Union{AmpLongModelResults,AmpShortModelResults}
    bl() = coefs[1] .+
            i.amp_model in [MAK3, MAKERGAUL4] ?
                coefs[2] .* cycs :
                0.0
    d0() = coefs[findfirst(bl.bl_fit.coef_syms .== :d0)]

    debug(logger, "at fit_amplification_model(::Type{Val{M}} where M <: DFCModel)")
    ## no fallback for baseline, because:
    ## (1) curve may fit well though :Error or :UserLimit
    ## (search step becomes very small but has not converge);
    ## (2) the guessed basedline (`start` of `fb`) is usually
    ## quite close to a sensible baseline.
    # const num_cycs = length(fluos)
    # const cycs = range(1.0, num_cycs)
    const num_cycs = i.num_cycs
    const cycs = i.cyc_nums ## allows non-contiguous sequences of cycles
    const wts = ones(num_cycs)
    ## fit model
    const bl_fit = fit(Val{M}, cycs, fluos, wts; solver = i.solver)
    const coefs = bl_fit.coefs
    const blsub_fluos = fluos .- bl()
    ## set output
    if R <: AmpShortModelResults
        return AmpShortModelResults(
            fluos, ## rbbs_3ary,
            blsub_fluos,
            NaN, ## dr1_pred
            NaN, ## dr2_pred
            NaN, ## cq
            d0())
    else
        return AmpLongModelResults(
            fluos, ## rbbs_3ary,
            bl_fit,
            [string(amp_model)], ## bl_notes
            blsub_fluos,
            bl_fit, ## quant_fit
            bl_fit.status, ## quant_status
            coefs, ## quant_coefs
            d0(),
            pred_from_cycs(Val{M}, cycs, coefs...), ## quant_fluos
            NaN, ## dr1_pred,
            NaN, ## dr2_pred,
            Inf, ## max_dr1
            Inf, ## max_dr2
            OrderedDict(), ## cyc_vals_4cq
            OrderedDict(), ## eff_vals_4cq
            NaN, ## cq_raw
            NaN, ## cq
            NaN, ## eff
            NaN) ## cq_fluo
    end ## if Q
end ## fit_amplification_model() where DFCModel

#=============================================================================================#

## fit_amplification_model() definition for SFC models
function fit_amplification_model(
    ::Type{Val{SFCModel}},
    ::Type{R},
    i                   ::AmpInput,
    fluos               ::AbstractVector,
    baseline_cyc_bounds ::AbstractArray,
    cq_method           ::CqMethod,
    ct_fluo             ::AbstractFloat,
) where R <: AmpModelResults
    @inline function SFC_wts()
        if i.bl_method in [lin_1ft, lin_2ft]
            _wts = zeros(num_cycs)
            _wts[colon(baseline_cyc_bounds...)] .= 1
            return _wts
        else
            ## some kind of sigmoid model is used to estimate amplification curve
            ## issue: why are `baseline_cyc_bounds` not baked into the weights as per above ???
            if num_cycs >= last_cyc_wt0
                return vcat(zeros(last_cyc_wt0), ones(num_cycs - last_cyc_wt0))
            else
                return zeros(num_cycs)
            end
        end
    end ## SFC_wts()

    @inline function good_status()
        if bl_status in [:Optimal, :UserLimit]
            const (min_bfd, max_bfd) = extrema(blsub_fluos) ## `bfd` - blsub_fluos_draft
            if !(max_bfd - min_bfd <= abs(min_bfd))
                push!(bl_notes, "model-derived baseline")
                return true
            else
                push!(bl_notes, "fallback")
                push!(bl_notes, "max_bfd ($max_bfd) - min_bfd ($min_bfd) " *
                    "== $(max_bfd - min_bfd) <= abs(min_bfd)")
                return false
            end
        end ## if bl_fit.status
        push!(bl_notes, "fallback")
        # (bl_status == :Error) && return false
        ## other status codes include
        ## :Infeasible, :Unbounded, :DualityFailure, and possibly others
        ## https://mathprogbasejl.readthedocs.io/en/latest/solverinterface.html
        ## My suggestion is to treat them all the same as :Error (TP Jan 2019):
        return false
        ## Alternatively, an error could be raised:
        # error(logger, ExceptionError("Baseline estimation returned " *
        #     "unrecognized termination status $(bl_status)"))
    end ## good_status()

    @inline function bl_cycs()
        const len_bcb = length(baseline_cyc_bounds)
        if !(len_bcb in [0, 2])
            throw(ArgumentError("length of `baseline_cyc_bounds` must be 0 or 2"))
        elseif len_bcb == 2
            push!(bl_notes, "user-defined")
            # baseline = i.bl_fallback_func(fluos[colon(baseline_cyc_bounds...)])
            return colon(baseline_cyc_bounds...)
        elseif len_bcb == 0 && last_cyc_wt0 > 1 && num_cycs >= i.min_reliable_cyc
            return auto_choose_bl_cycs()
        end
        ## fallthrough
        throw(DomainError("too few cycles to estimate baseline"))
    end ## bl_cycs()

    ## automatically choose baseline cycles as the flat part of the curve
    ## uses `fluos`, `last_cyc_wt0`; updates `bl_notes` using push!()
    ## `last_cyc_wt0 == floor(i.min_reliable_cyc) - 1`
    @inline function auto_choose_bl_cycs()
        const (min_fluo, min_fluo_cyc) = findmin(fluos)
        const dr2_cfd = finite_diff(cycs, fluos; nu = 2) ## `Dierckx.Spline1D` resulted in all `NaN` in some cases
        const dr2_cfd_left = dr2_cfd[1:min_fluo_cyc]
        const dr2_cfd_right = dr2_cfd[min_fluo_cyc:end]
        const (max_dr2_left_cyc, max_dr2_right_cyc) =
            map(index(2) ∘ findmax, (dr2_cfd_left, dr2_cfd_right))
        if max_dr2_right_cyc <= last_cyc_wt0
            ## fluo on fitted spline may not be close to raw fluo
            ## at `cyc_m2l` and `cyc_m2r`
            # push!(bl_notes, "max_dr2_right_cyc ($max_dr2_right_cyc) <= last_cyc_wt0 ($last_cyc_wt0), bl_cycs = $(last_cyc_wt0+1):$num_cycs")
            return colon(last_cyc_wt0+1, num_cycs)
        end
        ## max_dr2_right_cyc > last_cyc_wt0
        const bl_cyc_start = max(last_cyc_wt0+1, max_dr2_left_cyc)
        # push!(bl_notes, "max_dr2_right_cyc ($max_dr2_right_cyc) > last_cyc_wt0 ($last_cyc_wt0), bl_cyc_start = $bl_cyc_start (max(last_cyc_wt0+1, max_dr2_left_cyc), i.e. max($(last_cyc_wt0+1), $max_dr2_left_cyc))")
        if max_dr2_right_cyc - bl_cyc_start <= 1
            # push!(bl_notes, "max_dr2_right_cyc ($max_dr2_right_cyc) - bl_cyc_start ($bl_cyc_start) <= 1")
            if (max_dr2_right_cyc < num_cycs)
                const (max_dr2_right_2, max_dr2_right_cyc_2_shifted) =
                    findmax(dr2_cfd[max_dr2_right_cyc+1:end])
            else
                max_dr2_right_cyc_2_shifted = 0
            end
            const max_dr2_right_cyc_2 = max_dr2_right_cyc_2_shifted + max_dr2_right_cyc
            if max_dr2_right_cyc_2 - max_dr2_right_cyc <= 1
                const bl_cyc_end = num_cycs
                # push!(bl_notes, "max_dr2_right_cyc_2 ($max_dr2_right_cyc_2) - max_dr2_right_cyc ($max_dr2_right_cyc) == 1")
            else # max_dr2_right_cyc_2 - max_dr2_right_cyc != 1
                # push!(bl_notes, "max_dr2_right_cyc_2 ($max_dr2_right_cyc_2) - max_dr2_right_cyc ($max_dr2_right_cyc) != 1")
                const bl_cyc_end = max_dr2_right_cyc_2
            end ## if
        else ## cyc_m2r - bl_cyc_start > 1
            # push!(bl_notes, "max_dr2_right_cyc ($max_dr2_right_cyc) - bl_cyc_start ($bl_cyc_start) > 1")
            const bl_cyc_end = max_dr2_right_cyc
        end ## if
        # push!(bl_notes, "bl_cyc_end = $bl_cyc_end")
        const bl_cycs = bl_cyc_start:bl_cyc_end
        # push!(bl_notes, "bl_cycs = $bl_cyc_start:$bl_cyc_end")
        return bl_cycs
    end ## auto_choose_bl_cycs()

    function calc_cq_raw(;
        dr1_pred        ::Vector{Float_T} = zeros(0),
        dr2_pred        ::Vector{Float_T} = zeros(0),
    )
        (cq_method == cp_dr1) && return begin
                const _dr1_pred = sum(size(dr1_pred)) > 0 ?
                    dr1_pred :
                    funcs_pred[:dr1](cycs_denser, quant_coefs...)
                const idx_max_dr1 = findmax(_dr1_pred)[2]
                cycs_denser[idx_max_dr1]
            end
        (cq_method == cp_dr2) && return begin
                const _dr2_pred = sum(size(dr2pred)) > 0 ?
                    dr2pred :
                    funcs_pred[:dr2](cycs_denser, quant_coefs...)
                const idx_max_dr2 = findmax(_dr2_pred)[2]
                cycs_denser[idx_max_dr2]
            end
        (cq_method == Cy0) && return try
                const _dr1_pred = sum(size(dr1_pred)) > 0 ?
                    dr1_pred :
                    funcs_pred[:dr1](cycs_denser, quant_coefs...)
                const (max_dr1, idx_max_dr1) = findmax(_dr1_pred)
                const cyc_max_dr1 = cycs_denser[idx_max_dr1]
                cyc_max_dr1 - funcs_pred[:f](cyc_max_dr1, quant_coefs...) / max_dr1
            end ## try
        (cq_method == ct) && return try
                funcs_pred[:inv](ct_fluo, quant_coefs...)
            catch err
                isa(err, DomainError) ?
                    AMP_CT_VAL_DOMAINERROR :
                    rethrow()
            end ## try
        (cq_method == max_eff) && return begin
                const eff_pred = map(func_pred_eff, cycs_denser)
                const idx_max_eff = findmax(eff_pred)[2]
                cycs_denser[idx_max_eff]
            end
        ## fallthrough
        throw(ArgumentError("`cq_method` $cq_method not implemented"))
    end

    ## function needed because `Cy0` may not be in `cycs_denser`
    @inline function func_pred_eff(cyc)
        try
            -(map([0.5, -0.5]) do epsilon
                log2(funcs_pred[:f](cyc + epsilon, quant_coefs...))
            end...)
        catch err
            isa(err, DomainError) ?
                NaN :
                rethrow()
        end ## try
    end ## func_pred_eff()

    ## << end of function definitions nested within fit_baseline_model() ## SFC

    debug(logger, "at fit_amplification_model(Val{SFCModel})")
    #
    ## fit baseline model
    # const num_cycs = length(fluos)
    # const cycs = range(1.0, num_cycs)
    const num_cycs = i.num_cycs
    const cycs = i.cyc_nums ## allows non-contiguous sequences of cycles
    ## to determine weights (`wts`) for sigmoid fitting per `i.min_reliable_cyc`
    const last_cyc_wt0 = floor(i.min_reliable_cyc) - 1
    if i.bl_method in SFC_MODEL_NAMES
        ## fit model to find baseline
        const wts = SFC_wts()
        const bl_fit = i.SFC_model_defs[i.bl_method].func_fit(
            cycs, fluos, wts; solver = i.solver)
        const bl_status = bl_fit.status
        bl_notes = ["bl_status $bl_status"]
        baseline = i.SFC_model_defs[i.bl_method].funcs_pred[:bl](
            cycs, bl_fit.coefs...)
        blsub_fluos = fluos .- baseline
        const have_good_results = good_status()
        if !have_good_results
            ## recalculate baseline
            const bl_func = i.bl_fallback_func
        end
    else ## bl_method == take_the_median
        ## do not fit model to find baseline
        const wts = ones(num_cycs)
        const bl_fit = FIT[amp_model]() ## empty model fit
        const have_good_results = false
        bl_notes = ["no bl_status", "no fallback"]
        const bl_status = ""
        const bl_func = median
    end ## if bl_method
    if !have_good_results
        baseline = bl_func(fluos[bl_cycs()])
        blsub_fluos = fluos .- baseline
    end
    #
    ## fit quantitation model
    const qm = i.SFC_model_defs[i.quant_method]
    const quant_fit = qm.func_fit(cycs, blsub_fluos, wts; solver = i.solver)
    const quant_coefs = quant_fit.coefs
    const len_denser = i.denser_factor * (num_cycs - 1) + 1
    const cycs_denser = Array(range(1.0, 1.0/i.denser_factor, len_denser))
    const funcs_pred = qm.funcs_pred
    #
    ## do quantitation
    # calc_cq_fluo(cq_raw ::Real) = try
    #     funcs_pred[:f](cq_raw, quant_coefs...)
    #     catch err
    # isa(err, DomainError) ?
    #     NaN :
    #     rethrow()
    # end ## try
    @inline nonpos2NaN(x) = x <= zero(x) ? NaN : x
    @inline calc_cq_fluo(cq_raw ::Real) = funcs_pred[:f](nonpos2NaN(cq_raw), quant_coefs...)

    if R <: AmpCqFluoModelResults
        const cq_raw = calc_cq_raw()
        return AmpCqFluoModelResults(
            quant_fit.status, ## quant_status
            calc_cq_fluo(cq_raw)) ## cq_fluo
    end
    #
    const dr1_pred = funcs_pred[:dr1](cycs_denser, quant_coefs...)
    const dr2_pred = funcs_pred[:dr2](cycs_denser, quant_coefs...)
    const raw_cycs_index = colon(1, i.denser_factor, len_denser)
    if R <: AmpShortModelResults
        const cq_raw = calc_cq_raw(dr1_pred = dr1_pred, dr2_pred = dr2_pred)
        return AmpShortModelResults(
            fluos, ## rbbs_3ary,
            blsub_fluos,
            dr1_pred[raw_cycs_index],
            dr2_pred[raw_cycs_index],
            nonpos2NaN(cq_raw), ## cq
            NaN) ## d0
    end
    #
    const (max_dr1, idx_max_dr1) = findmax(dr1_pred)
    const cyc_max_dr1 = cycs_denser[idx_max_dr1]
    const (max_dr2, idx_max_dr2) = findmax(dr2_pred)
    const cyc_max_dr2 = cycs_denser[idx_max_dr2]
    const cy0 = cyc_max_dr1 - funcs_pred[:f](cyc_max_dr1, quant_coefs...) / max_dr1
    const ct = try
        funcs_pred[:inv](ct_fluo, quant_coefs...)
    catch err
        isa(err, DomainError) ?
            AMP_CT_VAL_DOMAINERROR :
            rethrow()
    end ## try
    const eff_pred = map(func_pred_eff, cycs_denser)
    const (eff_max, idx_max_eff) = findmax(eff_pred)
    const cyc_vals_4cq = OrderedDict(
        :cp_dr1  => cyc_max_dr1,
        :cp_dr2  => cyc_max_dr2,
        :Cy0     => cy0,
        :ct      => ct,
        :max_eff => cycs_denser[idx_max_eff])
    const cq_raw = cyc_vals_4cq[Symbol(cq_method)]
    const eff_vals_4cq =
        OrderedDict(
            map(keys(cyc_vals_4cq)) do key
                key => (key == :max_eff) ?
                    eff_max :
                    func_pred_eff(cyc_vals_4cq[key])
            end)
    return AmpLongModelResults(
        fluos, ## rbbs_3ary,
        bl_fit,
        bl_notes,
        blsub_fluos,
        quant_fit,
        quant_fit.status, ## quant_status
        quant_coefs,
        NaN, ## d0
        funcs_pred[:f](cycs, quant_coefs...), ## blsub_fitted
        dr1_pred[raw_cycs_index],
        dr2_pred[raw_cycs_index],
        max_dr1,
        max_dr2,
        cyc_vals_4cq,
        eff_vals_4cq,
        cq_raw,
        nonpos2NaN(cq_raw), ## cq
        copy(eff_vals_4cq[Symbol(cq_method)]), ## eff
        calc_cq_fluo(cq_raw)) ## cq_fluo
end ## fit_amplification_model(Val{SFCModel})