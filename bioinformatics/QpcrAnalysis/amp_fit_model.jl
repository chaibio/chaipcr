#===============================================================================

    amp_fit_model.jl

    function to fit amplification models
    this is a refactoring of the function
    previously called mod_bl_q() in amp.jl

    Author: Tom Price
    Date:   July 2019

===============================================================================#

## constant:
## a value that cannot be obtained by normal calculation of Ct
const AMP_CT_VAL_DOMAINERROR        = -99


#==============================================================================#


## amp_fit_model() definition for DFC models
"Model amplification data for a single well and channel."
function amp_fit_model(
    ::Type{Val{M}} where M <: DFCModel,
    ::Type{R},
    i                   ::AmpInput,
    fluos               ::Vector{Float_T},
    ## these parameters not used to fit DFC models
    baseline_cyc_bounds ::AbstractArray,
    cq_method           ::CqMethod,
    ct_fluo             ::Float_T,
) where R <: Union{AmpLongModelResults,AmpShortModelResults}
    bl() = coefs[1] .+
            i.amp_model in [MAK3, MAKERGAUL4] ?
                coefs[2] .* cycles :
                0.0
    d0() = coefs[findfirst(bl.bl_fit.coef_syms .== :d0)]

    debug(logger, "at amp_fit_model(::Type{Val{M}} where M <: DFCModel)")
    ## no fallback for baseline, because:
    ## (1) curve may fit well though :Error or :UserLimit
    ## (search step becomes very small but has not converge);
    ## (2) the guessed basedline (`start` of `fb`) is usually
    ## quite close to a sensible baseline.
    # const num_cycles = length(fluos)
    # const cycles = range(1.0, num_cycles)
    num_cycles = i.num_cycles
    cycles = Vector(i.cycles) ## allows non-contiguous sequences of cycles
    wts = ones(num_cycles)
    ## fit model
    bl_fit = fit(Val{M}, cycles, fluos, wts; solver = i.solver)
    coefs = bl_fit.coefs
    blsub_fluos = fluos .- bl()
    ## set output
    if isa(R, AmpShortModelResults)
        return AmpShortModelResults(
            fluos, ## rbbs_ary3,
            blsub_fluos,
            NaN_T, ## dr1_pred
            NaN_T, ## dr2_pred
            NaN_T, ## cq
            d0())
    else
        return AmpLongModelResults(
            fluos, ## rbbs_ary3,
            bl_fit,
            [string(amp_model)], ## bl_notes
            blsub_fluos,
            bl_fit, ## quant_fit
            bl_fit.status, ## quant_status
            coefs, ## quant_coefs
            d0(),
            pred_from_cycs(Val{M}, cycles, coefs...), ## quant_fluos
            NaN_T, ## dr1_pred,
            NaN_T, ## dr2_pred,
            Inf_T, ## max_dr1
            Inf_T, ## max_dr2
            OrderedDict(), ## cyc_vals_4cq
            OrderedDict(), ## eff_vals_4cq
            NaN_T, ## cq_raw
            NaN_T, ## cq
            NaN_T, ## eff
            NaN_T) ## cq_fluo
    end ## if Q
end ## fit_amplification_model() where DFCModel


#==============================================================================#


## fit_amplification_model() definition for SFC models
function amp_fit_model(
    ::Type{Val{SFCModel}},
    ::Type{R},
    i                   ::AmpInput,
    fluos               ::Vector{Float_T},
    baseline_cyc_bounds ::AbstractArray,
    cq_method           ::CqMethod,
    ct_fluo             ::Float_T,
) where R <: AmpModelResults
    "Calculates weights used to estimate the baseline by SFC model."
    @inline function SFC_wts()
        local wts
        debug(logger, "at SFC_wts")
        if i.bl_method == lin_1ft || i.bl_method == lin_2ft ## linear models
            wts = zeros(num_cycles)
            wts[bl_cycs()] .= 1
            return wts
        else
            ## some kind of sigmoid model is used to estimate amplification curve
            ## issue: why are `baseline_cyc_bounds` not baked into the weights as per above ???
            if num_cycles >= last_cyc_wt0
                return vcat(zeros(last_cyc_wt0), ones(num_cycles - last_cyc_wt0))
            else
                return zeros(num_cycles)
            end
        end
    end ## SFC_wts()

    "Check that the SFC model used to calculate the baseline terminated appropriately."
    @inline function good_status()
        if bl_status == :Optimal || bl_status == :UserLimit
            (min_bfd, max_bfd) = extrema(blsub_fluos) ## `bfd` - blsub_fluos_draft
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
        len_bcb = length(baseline_cyc_bounds)
        debug(logger, "at bl_cycs")
        if !(len_bcb in [0, 2])
            throw(ArgumentError("length of `baseline_cyc_bounds` must be 0 or 2"))
        elseif len_bcb == 2
            push!(bl_notes, "user-defined")
            return colon(baseline_cyc_bounds...)
        elseif len_bcb == 0 
            return auto_choose_bl_cycs()
        end
        ## fallthrough
        throw(ErrorException("too few cycles to estimate baseline"))
    end ## bl_cycs()

    ## uses `fluos`, `last_cyc_wt0`; updates `bl_notes` using push!()
    ## `last_cyc_wt0 == floor(i.min_reliable_cyc) - 1`
    "Automatically choose baseline cycles as the flat part of the curve."
    @inline function auto_choose_bl_cycs()
        debug(logger, "at auto_choose_bl_cycs")
        (min_fluo, min_fluo_cyc) = findmin(fluos)
        ## finite diff is used to estimate derivative because
        ## `Dierckx.Spline1D` resulted in all `NaN` in some cases
        dr2_cfd = finite_diff(cycles, fluos; nu = 2)

        dr2_cfd_left  = dr2_cfd[1:min_fluo_cyc]
        dr2_cfd_right = dr2_cfd[min_fluo_cyc:end]
        (max_dr2_left_cyc, max_dr2_right_cyc) =
            (dr2_cfd_left, dr2_cfd_right) |> mold(indmax)
        if max_dr2_right_cyc <= last_cyc_wt0
            ## fluo on fitted spline may not be close to raw fluo
            ## at `max_dr2_left_cyc` and `max_dr2_right_cyc`
            # push!(bl_notes, "max_dr2_right_cyc ($max_dr2_right_cyc) <= " *
            #     "last_cyc_wt0 ($last_cyc_wt0), bl_cycs = $(last_cyc_wt0+1):$num_cycles")
            return colon(last_cyc_wt0 + 1, num_cycles)
        end
        ## max_dr2_right_cyc > last_cyc_wt0
        bl_cyc_start = max(last_cyc_wt0 + 1, max_dr2_left_cyc)
        # push!(bl_notes, "max_dr2_right_cyc ($max_dr2_right_cyc) > " *
        #     "last_cyc_wt0 ($last_cyc_wt0), bl_cyc_start = $bl_cyc_start " *
        #     "(max(last_cyc_wt0+1, max_dr2_left_cyc), i.e. " *
        #     "max($(last_cyc_wt0+1), $max_dr2_left_cyc))")
        if max_dr2_right_cyc - bl_cyc_start <= 1
            # push!(bl_notes, "max_dr2_right_cyc ($max_dr2_right_cyc) - " *
            #     "bl_cyc_start ($bl_cyc_start) <= 1")
            if (max_dr2_right_cyc < num_cycles)
                (max_dr2_right_2, max_dr2_right_cyc_2_shifted) =
                    findmax(dr2_cfd[max_dr2_right_cyc + 1:end])
            else
                max_dr2_right_cyc_2_shifted = 0
            end
            max_dr2_right_cyc_2 = max_dr2_right_cyc_2_shifted + max_dr2_right_cyc
            if max_dr2_right_cyc_2 - max_dr2_right_cyc <= 1
                bl_cyc_end = num_cycles
                # push!(bl_notes, "max_dr2_right_cyc_2 ($max_dr2_right_cyc_2) - " *
                #     "max_dr2_right_cyc ($max_dr2_right_cyc) == 1")
            else
                ## max_dr2_right_cyc_2 - max_dr2_right_cyc > 1
                # push!(bl_notes, "max_dr2_right_cyc_2 ($max_dr2_right_cyc_2) - " *
                #     "max_dr2_right_cyc ($max_dr2_right_cyc) != 1")
                bl_cyc_end = max_dr2_right_cyc_2
            end ## if
        else
            ## max_dr2_right_cyc - bl_cyc_start > 1
            # push!(bl_notes, "max_dr2_right_cyc ($max_dr2_right_cyc) - " *
            #     "bl_cyc_start ($bl_cyc_start) > 1")
            bl_cyc_end = max_dr2_right_cyc
        end ## if
        # push!(bl_notes, "bl_cyc_end = $bl_cyc_end")
        # push!(bl_notes, "bl_cycles = $bl_cyc_start:$bl_cyc_end")
        return bl_cyc_start:bl_cyc_end
    end ## auto_choose_bl_cycs()

    denser_len(i , n :: Int_T) =
        i.denser_factor * (n - 1) + 1
    #
    interpolated_cycles() =
        range(1.0, 1.0/i.denser_factor, len_denser)

    ## functions used to calculate cq / cq_raw / cq_fluo >>

    dr1_pred_() =
        funcs_pred[:dr1](cycles_denser, quant_coefs...)
    #
    dr2_pred_() =
        funcs_pred[:dr2](cycles_denser, quant_coefs...)
    #
    cyc_max_dr1_(dr1_pred ::Vector{Float_T}) =
        cycles_denser[indmax(dr1_pred)]
    #
    cyc_max_dr2_(dr2_pred ::Vector{Float_T}) =
        cycles_denser[indmax(dr2_pred)]
    #
    cy0_(max_dr1 ::Float_T, idx_max_dr1 ::Int_T) =
        cy0_(max_dr1, idx_max_dr1, cycles_denser[idx_max_dr1])
    cy0_(max_dr1 ::Float_T, idx_max_dr1 ::Int_T, cyc_max_dr1 ::Float_T) =
        cyc_max_dr1 - funcs_pred[:f](cyc_max_dr1, quant_coefs...) / max_dr1
    #
    ct_() = try
        funcs_pred[:inv](ct_fluo, quant_coefs...)
    catch err
        isa(err, DomainError) ?
            AMP_CT_VAL_DOMAINERROR :
            rethrow()
    end ## ct_()
    #
    max_eff() = cycles_denser[indmax(map(func_pred_eff, cycles_denser))]
    #
    nonpos2NaN(x ::Float_T) =
        x <= zero(x) ? NaN_T : x
    #
    calc_cq_fluo(cq_raw ::Float_T) =
        funcs_pred[:f](nonpos2NaN(cq_raw), quant_coefs...)
    #
    @inline function calc_cq_raw()
        (cq_method == ct)      && return ct_()
        (cq_method == max_eff) && return max_eff_()
        calc_cq_raw(dr1_pred_())
    end
    @inline function calc_cq_raw(dr1_pred ::Vector{Float_T})
        (cq_method == cp_dr1)  && return cyc_max_dr1_(dr1_pred)
        (cq_method == Cy0)     && return cy0_(findmax(dr1_pred)...)
        calc_cq_raw(dr1_pred, dr2_pred_())
    end
    @inline function calc_cq_raw(dr1_pred ::Vector{Float_T}, dr2_pred ::Vector{Float_T})
        (cq_method == cp_dr2)  && return cyc_max_dr2_(dr2_pred)
        (cq_method == cp_dr1)  && return cyc_max_dr1_(dr1_pred)
        (cq_method == Cy0)     && return cy0_(findmax(dr1_pred)...)
        (cq_method == ct)      && return ct_()
        (cq_method == max_eff) && return max_eff_()
        ## fallthrough
        throw(ArgumentError("`cq_method` $cq_method not implemented"))
    end

    ## function needed because `Cy0` may not be in `cycles_denser`
    @inline function func_pred_eff(cyc)
        try
            -(map([0.5, -0.5]) do epsilon
                log2(funcs_pred[:f](cyc + epsilon, quant_coefs...))
            end...)
        catch err
            isa(err, DomainError) ?
                NaN_T :
                rethrow()
        end ## try
    end ## func_pred_eff()

    ## << end of function definitions nested within fit_baseline_model() ## SFC

    debug(logger, "at amp_fit_model(Val{SFCModel})")
    #
    ## fit baseline model
    # const num_cycles = length(fluos)
    # const cycles = range(1.0, num_cycles)
    ## the following allows non-contiguous sequences of cycles
    ## NB. Ipopt solver hangs unless cycles converted from SVector to Vector
    num_cycles = i.num_cycles
    cycles = Vector(i.cycles)
    ## to determine weights (`wts`) for sigmoid fitting per `i.min_reliable_cyc`
    last_cyc_wt0 = 0
    if i.bl_method in SFC_MODEL_NAMES
        ## fit model to find baseline
        wts = SFC_wts()
        len_denser = denser_len(i, num_cycles)
        cycles_denser = interpolated_cycles()
        bl_fit = i.SFC_model_def_func(i.bl_method).func_fit(
            cycles[i.min_reliable_cyc:end], fluos[i.min_reliable_cyc:end], wts; solver = i.solver)
        bl_status = bl_fit.status
        len_bcb = length(i.baseline_cyc_bounds)
        if len_bcb==0
            if (bl_status == :Optimal || bl_status == :UserLimit) #&& (abs(maximum(fluos)-minimum(fluos))>20000)
                dr2_pred_tm=i.SFC_model_def_func(i.bl_method).funcs_pred[:dr2](
                    cycles_denser, bl_fit.coefs...)
                min_fluo_cyc_=findmin(fluos)[2]
                if (min_fluo_cyc_<i.min_reliable_cyc)
                    fluos_muted=vcat(fill(findmax(fluos)[1],i.min_reliable_cyc-1),fluos[i.min_reliable_cyc:end])
                    min_fluo_cyc_=findmin(fluos_muted)[2]
                end
                approx_min_dr2=findmin(abs.(cycles_denser-min_fluo_cyc_))[2]
                basecyc_1st=i.min_reliable_cyc
                if !(min_fluo_cyc_==i.min_reliable_cyc)
                    dr2_left2mf=dr2_pred_tm[1:approx_min_dr2-1]
                    if !(all(dr2_left2mf.<dr2_pred_tm[approx_min_dr2]))
                        basecyc_1st=Int(floor(cycles_denser[findmax(dr2_left2mf)[2]]))
                        basecyc_1st=i.min_reliable_cyc<=basecyc_1st?basecyc_1st:i.min_reliable_cyc
                    end
                end

                if (min_fluo_cyc_==i.num_cycles || length(cycles_denser)==approx_min_dr2)
                    basecyc_last=i.num_cycles
                else
                    cycmax_dr2=findmax(dr2_pred_tm)[2]
                    if (cycmax_dr2 == approx_min_dr2)
                        basecyc_last=Int(floor(cycles_denser[cycmax_dr2]))
                    else
                        dr2_right2mf=dr2_pred_tm[approx_min_dr2+1:end]
                        basecyc_last=Int(floor(cycles_denser[findmax(dr2_right2mf)[2]+approx_min_dr2]))
                        basecyc_last=i.min_reliable_cyc==basecyc_last?i.num_cycles:basecyc_last
                    end
                end
                auto_cycs=basecyc_1st:basecyc_last
                baseline = median(fluos[auto_cycs])

                # my method, also worked:)
                # cyc_idx_=Int(floor(cycles_denser[findmax(dr2_pred_tm)[2]]))-1
                # println(cyc_idx_)
                # if cyc_idx_ <= i.min_reliable_cyc
                #     auto_cycs=cyc_idx_==0?bl_cycs():(1:cyc_idx_)
                #     baseline = i.SFC_model_def_func(i.bl_method).funcs_pred[:bl](
                #                          cycles_denser, bl_fit.coefs...)[1]
                # else
                #     auto_cycs=i.min_reliable_cyc:cyc_idx_
                #     baseline = median(fluos[auto_cycs])
                # end
            else
                auto_cycs=i.min_reliable_cyc:i.num_cycles
                baseline = median(fluos[auto_cycs])
            end
        else
            auto_cycs=i.baseline_cyc_bounds[1]:i.baseline_cyc_bounds[2]
            baseline = median(fluos[auto_cycs])
        end

        blsub_fluos= fluos .-baseline
        blsub_fluos_flb=blsub_fluos

        # debug(logger, "bl notes: $bl_notes, good_results: $have_good_results")
    else
        ## bl_method == take_the_median
        ## do not fit model to find baseline
        wts = ones(num_cycles)
        # bl_fit = FIT[amp_model]() ## empty model fit
        # have_good_results = false
        bl_notes = ["no bl_status", "no fallback"]
        bl_status = ""
        bl_func = median
        baseline = bl_func(fluos[bl_cycs()])
        blsub_fluos= fluos .- baseline
        blsub_fluos_flb=blsub_fluos
    end ## if bl_method
    # if !have_good_results
    #     blsub_fluos = blsub_fluos_flb
    # end
    #
    ## fit quantitation model
    qm = i.SFC_model_def_func(i.quant_method)
    quant_fit = qm.func_fit(cycles[auto_cycs[1]:end], blsub_fluos[auto_cycs[1]:end], wts; solver = i.solver)
    quant_coefs = quant_fit.coefs
    len_denser = denser_len(i, num_cycles)
    cycles_denser = interpolated_cycles()
    funcs_pred = qm.funcs_pred
	#if quant_fit.status==Symbol("Optimal")
	
    dr1_pred = dr1_pred_()
    dr2_pred = dr2_pred_()


	#end
    #
    ## results by R
    if R == AmpCqFluoModelResults
        ## the following method for calculating cq_raw
        ## is efficient for DEFAULT_AMP_CQ_FLUO_METHOD = cp_dr1
        cq_raw = calc_cq_raw(dr1_pred_())
        return AmpCqFluoModelResults(
            quant_fit.status, ## quant_status
            calc_cq_fluo(cq_raw)) ## cq_fluo
    end ## if
    #

    function discrete_dr1_dr2(fluos)
        len=length(fluos)
        dr1_val=zeros(len)
        dr2_val=zeros(len)
        dr2_val_v2=zeros(len)
        for el=1:len
            if el == 1
                dr1_val[el]=(fluos[el+1]-fluos[el])
            elseif el == len
                dr1_val[el]=(fluos[el]-fluos[el-1])
            else
                dr1_val[el]=(fluos[el+1]-fluos[el-1])/2
            end
        end
        for el=1:len
            if el == 1
                dr2_val[el]=(dr1_val[el+1]-dr1_val[el])
                dr2_val_v2[el]=dr2_val[el]
            elseif el == len
                dr2_val[el]=(dr1_val[el]-dr1_val[el-1])
                dr2_val_v2[el]=dr2_val[el]
            else
                dr2_val[el]=(fluos[el+1]+fluos[el-1]-2*fluos[el])
                dr2_val_v2[el]=(dr1_val[el+1]-dr1_val[el-1])/2
            end
        end
        return (dr1_val,dr2_val,dr2_val_v2)
    end
    #criteria_norm_err

    if R == AmpShortModelResults
        raw_cycs_index = colon(1, i.denser_factor, len_denser)
        dr1_values1,dr2_values1,dr2_values1_v2=discrete_dr1_dr2(fluos)
        return AmpShortModelResults(
            # fluos, ## rbbs_ary3,
            blsub_fluos,
            blsub_fluos_flb,
            dr1_pred[raw_cycs_index],
            dr2_pred[raw_cycs_index],
            dr1_values1,
            dr2_values1_v2,
            quant_fit.status,
            quant_coefs,
            nonpos2NaN(calc_cq_raw(dr1_pred, dr2_pred)), ## cq
            NaN_T) ## d0
    end ## R
    #
    ## R == AmpLongModelResults
    (max_dr1, idx_max_dr1) = findmax(dr1_pred)
    cyc_max_dr1 = cycles_denser[idx_max_dr1]
    (max_dr2, idx_max_dr2) = findmax(dr2_pred)
    cyc_max_dr2 = cycles_denser[idx_max_dr2]
    eff_pred = map(func_pred_eff, cycles_denser)
    (eff_max, idx_max_eff) = findmax(eff_pred)
    cyc_vals_4cq = OrderedDict(
        :cp_dr1  => cyc_max_dr1,
        :cp_dr2  => cyc_max_dr2,
        :Cy0     => cy0_(max_dr1, idx_max_dr1, cyc_max_dr1),
        :ct      => ct_(),
        :max_eff => cycles_denser[idx_max_eff])
    cq_raw = cyc_vals_4cq[Symbol(cq_method)]
    eff_vals_4cq =
        OrderedDict(
            map(keys(cyc_vals_4cq)) do key
                key => (key == :max_eff) ?
                    eff_max :
                    func_pred_eff(cyc_vals_4cq[key])
            end)
    return AmpLongModelResults(
        fluos, ## rbbs_ary3
        bl_fit,
        bl_notes,
        blsub_fluos,
        blsub_fluos_flb,
        quant_fit,
        quant_fit.status, ## quant_status
        quant_coefs,
        NaN_T, ## d0
        funcs_pred[:f](cycles, quant_coefs...), ## blsub_fitted
        dr1_pred[raw_cycs_index],
        dr2_pred[raw_cycs_index],
        dr1_values1,
        dr2_values1_v2,
        max_dr1,
        max_dr2,
        cyc_vals_4cq,
        eff_vals_4cq,
        cq_raw,
        nonpos2NaN(cq_raw), ## cq
        copy(eff_vals_4cq[Symbol(cq_method)]), ## eff
        calc_cq_fluo(cq_raw)) ## cq_fluo
end ## fit_amplification_model(Val{SFCModel})

