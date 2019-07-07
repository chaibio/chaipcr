## AmpBaselineModelFit.jl
##
## output from fit_baseline_model()
##
## Author: Tom Price
## Date:   July 2019

import DataStructures.OrderedDict
import Ipopt: IpoptSolver #, NLoptSolver


struct AmpBaselineModelFit
    fit_bl          ::AmpModelFit
    bl_notes        ::Vector{String}
    blsub_fluos     ::Vector{Float_T}
end


## default values for baseline model
const DEFAULT_AMP_MODEL             = SFCModel
const DEFAULT_AMP_BL_METHOD         = l4_enl
const DEFAULT_AMP_FALLBACK_FUNC     = median
const DEFAULT_AMP_CT_FLUOS          = Vector{Float_T}()
const DEFAULT_AMP_MIN_RELIABLE_CYC  = 5 ## >= 1
const DEFAULT_AMP_BL_CYC_BOUNDS     = Vector{Int}()


## fit_baseline_model() definitions >>

## DFC
function fit_baseline_model(
    ::Type{Val{M}} where M <: DFCModel,
    i                   ::AmpInput,
    o                   ::AmpOutput,
    fluos               ::AbstractVector;
) 
    debug(logger, "at fit_baseline_model(Val{M}) where M <: DFCModel")
    ## no fallback for baseline, because:
    ## (1) curve may fit well though :Error or :UserLimit
    ## (search step becomes very small but has not converge);
    ## (2) the guessed basedline (`start` of `fb`) is usually
    ## quite close to a sensible baseline.
    const amp_model = i.amp_model
    const num_cycs = length(fluos)
    const cycs = 1:num_cycs
    const wts = ones(num_cycs)
    const fit_bl = fit(Val{amp_model}, cycs, fluos, wts; solver = i.solver)
    const baseline =
        fit_bl.coefs[1] +
            amp_model in [MAK3, MAKERGAUL4] ?
                fit_bl.coefs[2] .* cycs : ## .+ ???
                0.0
    return AmpBaselineModelFit(
        fit_bl,
        [string(amp_model)], ## bl_notes
        fluos .- baseline) ## blsub_fluos
end ## fit_baseline_model(Val{M}) where M <: DFCModel


## SFC
function fit_baseline_model(
    ::Type{Val{SFCModel}},
    i                   ::AmpInput,
    o                   ::AmpOutput,
    fluos               ::AbstractVector;
    SFC_model_defs      ::OrderedDict{SFCModelName, SFCModelDef} = SFC_MDs,
    bl_method           ::SFCModelName = DEFAULT_AMP_MODEL_NAME,
    bl_fallback_func    ::Function = DEFAULT_AMP_FALLBACK_FUNC,
    min_reliable_cyc    ::Real = DEFAULT_AMP_MIN_RELIABLE_CYC,
    baseline_cyc_bounds ::AbstractArray = DEFAULT_AMP_BASELINE_CYC_BOUNDS
)
    function SFC_wts()
        if bl_method in [lin_1ft, lin_2ft]
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

    ## update bl_notes
    function SFC_bl_status(bl_status ::Symbol)
        bl_notes = ["bl_status $bl_status", "model-derived baseline"]
        if bl_status in [:Optimal, :UserLimit]
            const (min_bfd, max_bfd) = extrema(blsub_fluos) ## `bfd` - blsub_fluos_draft
            if max_bfd - min_bfd <= abs(min_bfd)
                bl_notes[2] = "fallback"
                push!(bl_notes, "max_bfd ($max_bfd) - min_bfd ($min_bfd) == $(max_bfd - min_bfd) <= abs(min_bfd)")
            end ## if max_bfd - min_bfd
        elseif bl_status == :Error
            bl_notes[2] = "fallback"
        else
            ## other status codes include
            ## ::Infeasible, :Unbounded, :DualityFailure, and possibly others
            ## https://mathprogbasejl.readthedocs.io/en/latest/solverinterface.html
            ## My suggestion is to treat the same as :Error (TP Jan 2019):
            bl_notes[2] = "fallback"
            ## Alternatively, an error could be raised:
            # error(logger, "Baseline estimation returned unrecognized termination status $bl_status")
        end ## if bl_status
        return bl_notes
    end ## SFC_bl_status()

    function bl_cycs()
        const len_bcb = length(baseline_cyc_bounds)
        if !(len_bcb in [0, 2])
            throw(ArgumentError("length of `baseline_cyc_bounds` must be 0 or 2"))
        elseif len_bcb == 2
            push!(bl_notes, "User-defined")
            # baseline = bl_fallback_func(fluos[colon(baseline_cyc_bounds...)])
            return colon(baseline_cyc_bounds...)
        elseif len_bcb == 0 && last_cyc_wt0 > 1 && num_cycs >= min_reliable_cyc
            return auto_choose_bl_cycs()
        end
        ## fallthrough
        throw(DomainError("too few cycles to estimate baseline"))
    end ## bl_cycs()

    ## automatically choose baseline cycles as the flat part of the curve
    ## uses `fluos`, `last_cyc_wt0`; updates `bl_notes` using push!()
    ## `last_cyc_wt0 == floor(min_reliable_cyc) - 1`
    function auto_choose_bl_cycs()
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

    ## << end of function definitions nested within fit_baseline_model() ## SFC

    debug(logger, "at fit_baseline_model(Val{SFCModel})")
    const num_cycs = length(fluos)
    const cycs = 1:num_cycs
    ## to determine weights (`wts`) for sigmoid fitting per `min_reliable_cyc`
    const last_cyc_wt0 = floor(min_reliable_cyc) - 1
    if bl_method in keys(SFC_model_defs)
        ## fit model to find baseline
        const wts = SFC_wts()
        const fit_bl = SFC_model_defs[bl_method].func_fit(
            cycs, fluos, wts; solver = i.solver)
        baseline = SFC_model_defs[bl_method].funcs_pred[:bl](cycs, fit_bl.coefs...) ## may be changed later
        blsub_fluos = fluos .- baseline
        bl_notes = SFC_bl_status(fit_bl.status)
        if length(bl_notes) >= 2 && bl_notes[2] == "fallback"
            const bl_func = bl_fallback_func
        end
    else
        ## do not fit model to find baseline
        const wts = ones(num_cycs)
        const fit_bl = FIT[amp_model]() ## empty model fit
        bl_notes = ["no bl_status", "no fallback"]
        if bl_method == :median
            const bl_func = median
        else
            ## `bl_func` undefined
            throw(ArgumentError("baseline estimation function `bl_func` " *
                "not defined for `bl_method` $bl_method"))
        end ## if bl_method
    end ## if
    if length(bl_notes) < 2 || bl_notes[2] != "model-derived baseline"
        baseline = bl_func(fluos[bl_cycs()]) ## change or new def
        blsub_fluos = fluos .- baseline
    end      
    return AmpBaselineModelFit(
        fit_bl,
        bl_notes,
        blsub_fluos)
end ## fit_baseline_model(Val{SFCModel})
