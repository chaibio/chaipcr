## Amp.jl
##
## struct of data and analysis parameters in amplification.jl
##
## Author: Tom Price
## Date:   July 2019

import DataStructures.OrderedDict


struct Amp
    ## input data
    raw_data                ::AmpRawData
    num_cycs                ::Int
    num_fluo_wells          ::Int
    num_channels            ::Int
    cyc_nums                ::Vector{Int}
    fluo_well_nums          ::Vector{Int}
    channels                ::Vector{Symbol}
    calibration_data        ::CalibrationData
    ## solver
    solver                  ::IpoptSolver
    ipopt_print2file_prefix ::String
    ## calibration parameters
    dcv                     ::Bool
    ## amplification model
    amp_model               ::AmpModel
    ## output format parameters
    # out_sr_dict             ::Bool
    out_format              ::Symbol
    reporting               ::Function
    ## keyword arguments
    min_reliable_cyc        ::Integer
    baseline_cyc_bounds     ::AbstractVector
    cq_method               ::Symbol
    bl_method               ::Symbol
    bl_fallback_func        ::Symbol
    max_bsf_lb              ::Integer
    max_dr1_lb              ::Integer
    max_dr2_lb              ::Integer
    ctrl_well_dict          ::OrderedDict{Vector{Int},Vector{Int}}
end


## constants >>

## default for calibration
const DEFAULT_AMP_DCV                   = true

## defaults for baseline model
const DEFAULT_AMP_MODEL                 = SFC
const DEFAULT_AMP_BL_METHOD             = :l4_enl
const DEFAULT_AMP_MODEL_DEF             = SFC_MDs[DEFAULT_AMP_MODEL_NAME]
const DEFAULT_AMP_FALLBACK_FUNC         = median
const DEFAULT_AMP_CT_FLUOS              = []
const DEFAULT_AMP_MIN_RELIABLE_CYC      = 5 ## >= 1
const DEFAULT_AMP_BASELINE_CYC_BOUNDS   = []
const DEFAULT_AMP_CQ_METHOD             = :Cy0


## defaults for report_cq!()
## note for default scaled_max_dr1_lb:
## 'look like real amplification, scaled_max_dr1 0.00894855, ip223, exp. 75, well A7, channel 2`
const DEFAULT_AMP_QT_PROB           = 0.9
const DEFAULT_AMP_BEFORE_128X       = false
const DEFAULT_AMP_MAX_DR1_LB        = 472
const DEFAULT_AMP_MAX_DR2_LB        = 41
const DEFAULT_AMP_MAX_BSF_LB        = 4356
const DEFAULT_AMP_SCALED_MAX_DR1_LB = 0.0089
const DEFAULT_AMP_SCALED_MAX_DR2_LB = 0.000689
const DEFAULT_AMP_SCALED_MAX_BSF_LB = 0.086

## defaults for process_ad()
const DEFAULT_AMP_CYCS              = 0
const DEFAULT_AMP_CTRL_WELL_DICT    = CTRL_WELL_DICT
const DEFAULT_AMP_CLUSTER_METHOD    = k_means_medoids
const DEFAULT_AMP_NORM_L            = 2
const DEFAULT_AMP_DEFAULT_ENCGR     = DEFAULT_encgr
const DEFAULT_AMP_CATEG_WELL_VEC    = CATEG_WELL_VEC

## default for asrp_vec
# const DEFAULT_AMP_CYC_NUMS          = Vector{Int}()

## a value that cannot be obtained by normal calculation of Ct
const AMP_CT_VAL_DOMAINERROR = -99 


## methods >>

## constructor
Amp(
    raw_data                ::AmpRawData,
    num_cycs                ::Int,
    num_fluo_wells          ::Int,
    num_channels            ::Int,
    cyc_nums                ::Vector{Int},
    fluo_well_nums          ::Vector{Int},
    channels                ::Vector{Symbol},
    calibration_data        ::CalibrationData,
    solver                  ::IpoptSolver,
    ipopt_print2file_prefix ::String,
    dcv                     ::Bool,
    amp_model               ::AmpModel,
    # out_sr_dict             ::Bool,
    out_format              ::Symbol,
    reporting               ::Function;
    min_reliable_cyc        ::Integer = DEFAULT_AMP_MIN_RELIABLE_CYC,
    baseline_cyc_bounds     ::AbstractVector = DEFAULT_AMP_BASELINE_CYC_BOUNDS,
    cq_method               ::Symbol = DEFAULT_AMP_CQ_METHOD,
    bl_method               ::Symbol = DEFAULT_AMP_BL_METHOD,
    bl_fallback_func        ::Symbol = DEFAULT_AMP_FALLBACK_FUNC,
    max_bsf_lb              ::Integer = DEFAULT_AMP_MAX_DR1_LB,
    max_dr1_lb              ::Integer = DEFAULT_AMP_MAX_DR2_LB,
    max_dr2_lb              ::Integer = DEFAULT_AMP_MAX_BSF_LB,
    ctrl_well_dict          ::OrderedDict{Vector{Int},Vector{Int}} =
                                        DEFAULT_AMP_CTRL_WELL_DICT,
) =
    Amp(
        raw_data,
        num_cycs,
        num_fluo_wells,
        num_channels,
        cyc_nums,
        fluo_well_nums,
        channels,
        calibration_data,
        solver,
        ipopt_print2file_prefix,
        dcv,
        amp_model,
        # out_sr_dict,
        out_format,
        reporting,
        min_reliable_cyc,
        baseline_cyc_bounds,
        cq_method,
        bl_method,
        bl_fallback_func,
        max_bsf_lb,
        max_dr1_lb,
        max_dr2_lb,
        ctrl_well_dict)

## helper function
amp_init(this ::Amp, x...) = fill(x..., this.num_fluo_wells, this.num_channels)

function amp_check_baseline_cyc_bounds(
    this                    ::Amp,
    baseline_cyc_bounds     ::AbstractVector,
)
    debug(logger, "at amp_check_baseline_cyc_bounds()")
    (this.num_cycs <= 2) && return baseline_cyc_bounds
    const size_bcb = size(baseline_cyc_bounds)
    if size_bcb == (0,) || (size_bcb == (2,) && size(baseline_cyc_bounds[1]) == ()) ## can't use `eltype(baseline_cyc_bounds) <: Integer` because `JSON.parse("[1,2]")` results in `Any[1,2]` instead of `Int[1,2]`
        return amp_init(this, baseline_cyc_bounds)
    elseif size_bcb == (this.num_fluo_wells, this.num_channels) &&
        eltype(baseline_cyc_bounds) <: AbstractVector ## final format of `baseline_cyc_bounds`
        return baseline_cyc_bounds
    end
    throw(ArgumentError("`baseline_cyc_bounds` is not in the right format"))
end ## amp_check_baseline_cyc_bounds()

function amp_calc_ct_fluos(
    this                    ::Amp,
    ct_fluos                ::AbstractVector,
    baseline_cyc_bounds     ::AbstractVector,
)
    debug(logger, "at amp_calc_ct_fluos()")
    const ct_fluos_empty = fill(NaN, this.num_channels)
    (this.num_cycs <= 2)     && return ct_fluos
    (length(ct_fluos) > 0)   && return ct_fluos
    (this.cq_method != :ct)  && return ct_fluos_empty
    (this.amp_model != :SFC) && return ct_fluos_empty
    ## else
    map(1:this.num_channels) do channel_i
        const fit_array1 =
            map(1:this.num_fluo_wells) do well_i
                const kwargs = this.amp_model == SFC ?
                    Dict{Symbol, Any}(
                        baseline_cyc_bounds => baseline_cyc_bounds[well_i, channel_i],
                        min_reliable_cyc => min_reliable_cyc,
                        this.kwargs_bl...)
                const fit_bl =
                    fit_baseline_model(
                        Val{this.amp_model},
                        this.calibrated_data[:, well_i, channel_i],
                        this.solver;
                        kwargs_bl)
                        ## parameters that apply only when fitting SFC models
                        kwargs_bl = Dict(
                            kwargs_fit...)) ## passed from request
                        # cq_method = :cp_dr1,
                        # ct_fluo = NaN)
            end ## do well_i
        fit_array1 |>
            mold(index(:postbl_status)) |>
            find_idc_useful |>
            mold(fit_i -> fit_array1[fit_i][:cq_fluo]) |>
            median
    end ## do channel_i
end ## amp_calc_ct_fluos()

## analyse amplification per step/ramp
function amp_process_1sr(
    this                    ::Amp;
    # asrp                    ::AmpStepRampProperties,
    out_format              ::Symbol = :pre_json ## :full, :pre_json
)
    debug(logger, "at amp_process_1sr()")
    ## deconvolute and normalize
    const (background_subtracted_data, k4dcv, deconvoluted_data,
            norm_data, norm_well_nums, calibrated_data) =
        calibrate(
            this.raw_data,
            this.calibration_data,
            this.fluo_well_nums,
            this.channel_nums,
            this.dcv,
            :array)
    ## initialize output
    full_amp_out = AmpStepRampOutput(
        this.raw_data,
        background_subtracted_data,
        k4dcv,
        deconvoluted_data,
        norm_data,
        calibrated_data,
        this.fluo_well_nums,
        this.num_channels,
        # cq_method,
        DEFAULT_AMP_CT_FLUOS)
    #
    # kwargs_jmp_model = Dict(:solver => this.solver)
    if num_cycs <= 2
        warn(logger, "number of cycles $num_cycs <= 2: baseline subtraction " *
            "and Cq calculation will not be performed")
    else ## num_cycs > 2
        ## calculate ct_fluos
        const baseline_cyc_bounds =
            amp_check_baseline_cyc_bounds(this, DEFAULT_AMP_BASELINE_CYC_BOUNDS)
        full_amp_out.ct_fluos =
            amp_calc_ct_fluos(this, DEFAULT_AMP_CT_FLUOS, baseline_cyc_bounds)
        ## baseline model fit
        const fit_array2 = calc_fit_array2()
        foreach fieldname in fieldnames(AmpModelFitOutput) do fieldname
            set_field_from_array!(full_amp_out, fieldname, fit_array2)
        end ## do fieldname
        ## quantification
        const quant_array2 = calc_quant_array2(fit_array2)
        foreach fieldname in fieldnames(AmpQuantOutput) do fieldname
            set_field_from_array!(full_amp_out, fieldname, quant_array2)
        end ## do fieldname
        ## qt_fluos
        set_qt_fluos!()
        ## report_cq
        set_fieldname_rcq!()
    end ## if
    #
    ## allelic discrimination
    # if dcv
    #     full_amp_out.assignments_adj_labels_dict, full_amp_out.agr_dict =
    #         process_ad(
    #             full_amp_out,
    #             kwargs_ad...)
    # end # if dcv
    #
    ## format output
    return (out_format == :full) ?
        full_amp_out :
        AmpStepRampOutput2Bjson(full_amp_out, reporting)
end ## amp_process_1sr()


function calc_fit_array2()
    debug(logger, "at calc_fit_array2()")
    [
        begin
            ipopt_print2file = length(ipopt_print2file_prefix) == 0 ?
                "" : "$(join([ipopt_print2file_prefix, channel_i, well_i], '_')).txt"
            fit_baseline_model(
                Val{amp_model},
                calibrated_data[:, well_i, channel_i],
                kwargs_jmp_model;
                amp_model = amp_model,
                ipopt_print2file = ipopt_print2file,
                ## parameters that apply only when fitting SFC models
                kwargs_bl = Dict(
                    baseline_cyc_bounds => checked_baseline_cyc_bounds[well_i, channel_i],
                    min_reliable_cyc => min_reliable_cyc,
                    kwargs_fit...)) ## passed from request
                # cq_method = cq_method,
                # ct_fluo = calculated_ct_fluos[channel_i]),
        end
        for well_i in 1:num_fluo_wells, channel_i in 1:num_channels
    ]
end ## calc_fit_array2()

function calc_quant_array2(fit_array2 ::AbstractArray)
    debug(logger, "at calc_quant_array2()")
    [
        amp_model == SFC ?
            quantify(
                Val{amp_model},
                fit_array2[well_i, channel_i];
                cq_method = cq_method,
                ct_fluo = calculated_ct_fluos[channel_i]),
            ) :
            AmpQuantOutput()
        for well_i in 1:num_fluo_wells, channel_i in 1:num_channels
    ]
end ## calc_quant_array2()

function set_qt_fluos!()
    debug(logger, "at set_qt_fluos!()")
    full_amp_out.qt_fluos =
        [   quantile(full_amp_out.blsub_fluos[:, well_i, channel_i], qt_prob_rc)
            for well_i in 1:num_fluo_wells, channel_i in 1:num_channels             ]
    full_amp_out.max_qt_fluo = maximum(full_amp_out.qt_fluos)
    return nothing ## side effects only
end

function set_fieldname_rcq!()
    debug(logger, "at set_fn_rcq!()")
    for well_i in 1:num_fluo_wells, channel_i in 1:num_channels
        report_cq!(full_amp_out, well_i, channel_i; kwargs_rc...)
    end
    return nothing ## side effects only
end

## << end of function definitions nested within process_amp_1sr



function report_cq!(
    full_amp_out        ::AmpStepRampOutput,
    well_i              ::Integer,
    channel_i           ::Integer;
    before_128x         ::Bool = DEFAULT_RCQ_BEFORE_128X,
    max_dr1_lb          ::Integer = DEFAULT_RCQ_MAX_DR1_LB,
    max_dr2_lb          ::Integer = DEFAULT_RCQ_MAX_DR2_LB,
    max_bsf_lb          ::Integer = DEFAULT_RCQ_MAX_BSF_LB,
    scaled_max_dr1_lb   ::AbstractFloat = DEFAULT_RCQ_SCALED_MAX_DR1_LB, 
    scaled_max_dr2_lb   ::AbstractFloat = DEFAULT_RCQ_SCALED_MAX_DR2_LB,
    scaled_max_bsf_lb   ::AbstractFloat = DEFAULT_RCQ_SCALED_MAX_BSF_LB,
)
    if before_128x
        max_dr1_lb, max_dr2_lb, max_bsf_lb = [max_dr1_lb, max_dr2_lb, max_bsf_lb] ./ 128
    end
    #
    const num_cycs = size(full_amp_out.raw_data, 1)
    const (postbl_status, cq_raw, max_dr1, max_dr2) =
        map([ :postbl_status, :cq_raw, :max_dr1, :max_dr2 ]) do fieldname
            fieldname -> getfield(full_amp_out, fieldname)[well_i, channel_i]
        end 
    const max_bsf = maximum(full_amp_out.blsub_fluos[:, well_i, channel_i])
    const b_ = full_amp_out.coefs[1, well_i, channel_i]
    const (scaled_max_dr1, scaled_max_dr2, scaled_max_bsf) =
        [max_dr1, max_dr2, max_bsf] ./ full_amp_out.max_qt_fluo
    const why_NaN =
        if postbl_status == :Error
            "postbl_status == :Error"
        elseif b_ > 0
            "b > 0"
        elseif full_amp_out.cq_method == :ct && cq_raw == CT_VAL_DOMAINERROR
            "DomainError when calculating Ct"
        elseif cq_raw <= 0.1 || cq_raw >= num_cycs
            "cq_raw <= 0.1 || cq_raw >= num_cycs"
        elseif max_dr1 < max_dr1_lb
            "max_dr1 $max_dr1 < max_dr1_lb $max_dr1_lb"
        elseif max_dr2 < max_dr2_lb
            "max_dr2 $max_dr2 < max_dr2_lb $max_dr2_lb"
        elseif max_bsf < max_bsf_lb
            "max_bsf $max_bsf < max_bsf_lb $max_bsf_lb"
        elseif scaled_max_dr1 < scaled_max_dr1_lb
            "scaled_max_dr1 $scaled_max_dr1 < scaled_max_dr1_lb $scaled_max_dr1_lb"
        elseif scaled_max_dr2 < scaled_max_dr2_lb
            "scaled_max_dr2 $scaled_max_dr2 < scaled_max_dr2_lb $scaled_max_dr2_lb"
        elseif scaled_max_bsf < scaled_max_bsf_lb
            "scaled_max_bsf $scaled_max_bsf < scaled_max_bsf_lb $scaled_max_bsf_lb"
        else
            ""
        end ## why_NaN
    (why_NaN != "") && (full_amp_out.cq[well_i, channel_i] = NaN)
    #
    for tup in (
        (:max_bsf,        max_bsf),
        (:scaled_max_dr1, scaled_max_dr1),
        (:scaled_max_dr2, scaled_max_dr2),
        (:scaled_max_bsf, scaled_max_bsf),
        (:why_NaN,        why_NaN))
        getfield(full_amp_out, tup[1])[well_i, channel_i] = tup[2]
    end
    return nothing ## side effects only
end ## report_cq!
