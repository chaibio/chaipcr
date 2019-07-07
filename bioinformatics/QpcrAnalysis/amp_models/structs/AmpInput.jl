## AmpInput.jl
##
## struct of data and analysis parameters in amplification.jl
##
## Author: Tom Price
## Date:   July 2019

import DataStructures.OrderedDict
import Ipopt: IpoptSolver #, NLoptSolver


## enum >>

@enum AmpOutputOption long short cq_only

AmpOutputOption(option ::OutputFormat) =
    option == full ? long : short


## structs >>

struct AmpInput{F}
    ## input data
    raw_data                ::AmpRawData{F}
    num_cycs                ::Int
    num_fluo_wells          ::Int
    num_channels            ::Int
    cyc_nums                ::Vector{Int}
    fluo_well_nums          ::Vector{Int}
    channel_nums            ::Vector{Int}
    calibration_data        ::CalibrationData
    ## solver
    solver                  ::IpoptSolver
    ipopt_print2file_prefix ::String
    ## calibration parameters
    dcv                     ::Bool
    ## amplification model
    amp_model               ::Type{M} where {M <: AmpModel}
    ## output format parameters
    # out_sr_dict             ::Bool
    amp_output              ::AmpOutputOption
    reporting               ::Function
    ## keyword arguments
    min_reliable_cyc        ::Integer
    baseline_cyc_bounds     ::AbstractVector
    cq_method               ::CqMethod
    bl_method               ::SFCModelName
    bl_fallback_func        ::Function
    max_bsf_lb              ::Integer
    max_dr1_lb              ::Integer
    max_dr2_lb              ::Integer
    ctrl_well_dict          ::OrderedDict{Vector{Int},Vector{Int}}
end


## constants >>

## default for calibration
const DEFAULT_AMP_DCV               = true

## defaults for process_ad()
const DEFAULT_AMP_CYCS              = 0
const DEFAULT_AMP_CTRL_WELL_DICT    = CTRL_WELL_DICT
const DEFAULT_AMP_CLUSTER_METHOD    = k_means_medoids
const DEFAULT_AMP_NORM_L            = 2
const DEFAULT_AMP_DEFAULT_ENCGR     = DEFAULT_encgr
const DEFAULT_AMP_CATEG_WELL_VEC    = CATEG_WELL_VEC


## methods >>

## constructor
AmpInput(
    raw_data                ::AmpRawData{F},
    num_cycs                ::Int,
    num_fluo_wells          ::Int,
    num_channels            ::Int,
    cyc_nums                ::Vector{Int},
    fluo_well_nums          ::Vector{Int},
    channel_nums            ::Vector{Int},
    calibration_data        ::CalibrationData,
    solver                  ::IpoptSolver,
    ipopt_print2file_prefix ::String,
    dcv                     ::Bool,
    amp_model               ::Type{M} where {M <: AmpModel},
    # out_sr_dict             ::Bool,
    amp_output              ::OutputFormat,
    reporting               ::Function;
    min_reliable_cyc        ::Integer = DEFAULT_AMP_MIN_RELIABLE_CYC,
    baseline_cyc_bounds     ::AbstractVector = DEFAULT_AMP_BASELINE_CYC_BOUNDS,
    cq_method               ::CqMethod = DEFAULT_AMP_CQ_METHOD,
    bl_method               ::SFCModelName = DEFAULT_AMP_BL_METHOD,
    bl_fallback_func        ::Function = DEFAULT_AMP_FALLBACK_FUNC,
    max_bsf_lb              ::Integer = DEFAULT_AMP_MAX_DR1_LB,
    max_dr1_lb              ::Integer = DEFAULT_AMP_MAX_DR2_LB,
    max_dr2_lb              ::Integer = DEFAULT_AMP_MAX_BSF_LB,
    ctrl_well_dict          ::OrderedDict{Vector{Int},Vector{Int}} =
                                        DEFAULT_AMP_CTRL_WELL_DICT,
) where {F <: Real} = 
    AmpInput{F}(
        raw_data,
        num_cycs,
        num_fluo_wells,
        num_channels,
        cyc_nums,
        fluo_well_nums,
        channel_nums,
        calibration_data,
        solver,
        ipopt_print2file_prefix,
        dcv,
        amp_model,
        # out_sr_dict,
        amp_output,
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


## analyse amplification per step/ramp
function amp_process_1sr(i ::AmpInput) # ; asrp ::AmpStepRampProperties)
    debug(logger, "at amp_process_1sr()")
    ## deconvolute and normalize
    const calibration_results =
        calibrate(
            i.raw_data,
            i.calibration_data,
            i.fluo_well_nums,
            i.channel_nums;
            dcv = i.dcv,
            data_format = array)
    ## initialize output
    o = AmpOutput(
        Val{amp_output},
        i,
        calibrated_results...,
        # cq_method,
        DEFAULT_AMP_CT_FLUOS)
    # kwargs_jmp_model = Dict(:solver => this.solver)
    if i.num_cycs <= 2
        warn(logger, "number of cycles $num_cycs <= 2: baseline subtraction " *
            "and Cq calculation will not be performed")
    else ## num_cycs > 2
        const baseline_cyc_bounds = check_bl_cyc_bounds(i, DEFAULT_AMP_BL_CYC_BOUNDS)
        ## calculate ct_fluos
        o.ct_fluos = calc_ct_fluos(o, i, DEFAULT_AMP_CT_FLUOS, baseline_cyc_bounds)
        ## baseline model fit
        const fit_array2 = calc_fit_array2(o, i, baseline_cyc_bounds)
        foreach(fieldnames(AmpModelFitOutput)) do fieldname
            set_field_from_array!(o, fieldname, fit_array2)
        end ## do fieldname
        ## quantification
        const quant_array2 = calc_quant_array2(o, fit_array2)
        foreach(fieldnames(AmpQuantOutput)) do fieldname
            set_field_from_array!(o, fieldname, quant_array2)
        end ## do fieldname
        ## qt_fluos
        set_qt_fluos!(o)
        ## report_cq
        set_fieldname_rcq!(o)
    end ## if
    #
    ## allelic discrimination
    # if dcv
    #     o.assignments_adj_labels_dict, o.agr_dict =
    #         process_ad(
    #             o,
    #             kwargs_ad...)
    # end # if dcv
    #
    ## format output
    return o
end ## amp_process_1sr()


## helper functions >>

amp_init(i ::AmpInput, x...) = fill(x..., i.num_fluo_wells, i.num_channels)

## baseline estimation parameters
kwargs_bl(i ::AmpInput) =
    Dict{Symbol,Any}(
        :min_reliable_cyc    => i.min_reliable_cyc,
        :bl_method           => i.bl_method,
        :bl_fallback_func    => i.bl_fallback_func)

## baseline estimation parameters
kwargs_quant(i ::AmpInput) =
    Dict{Symbol,Any}(
        :cq_method           => i.cq_method)

function check_bl_cyc_bounds(
    i               ::AmpInput,
    bl_cyc_bounds   ::Union{Vector{I},Array{Vector{I},2}} where {I <: Integer},
)
    debug(logger, "at check_bl_cyc_bounds()")
    (i.num_cycs <= 2) && return bl_cyc_bounds
    const size_bcb = size(bl_cyc_bounds)
    if size_bcb == (0,) || size_bcb == (2,)
        return amp_init(i, bl_cyc_bounds)
    elseif size_bcb == (i.num_fluo_wells, i.num_channels) &&
        eltype(bl_cyc_bounds) <: AbstractVector ## final format of `baseline_cyc_bounds`
            return bl_cyc_bounds
    end
    throw(ArgumentError("`baseline_cyc_bounds` is not in the right format"))
end ## check_bl_cyc_bounds()
