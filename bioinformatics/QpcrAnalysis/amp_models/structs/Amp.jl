## AmpInput.jl
##
## struct of data and analysis parameters in amplification.jl
##
## Author: Tom Price
## Date:   July 2019

import DataStructures.OrderedDict
import Ipopt: IpoptSolver #, NLoptSolver


struct AmpInput
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
    # results                 ::AmpOutput,
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
    AmpInput(
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
init(i ::AmpInput, x...) = fill(x..., i.num_fluo_wells, i.num_channels)


function check_baseline_cyc_bounds(
    i                       ::AmpInput,
    baseline_cyc_bounds     ::AbstractVector,
)
    debug(logger, "at check_baseline_cyc_bounds()")
    (i.num_cycs <= 2) && return baseline_cyc_bounds
    const size_bcb = size(baseline_cyc_bounds)
    if size_bcb == (0,) || (size_bcb == (2,) && size(baseline_cyc_bounds[1]) == ()) ## can't use `eltype(baseline_cyc_bounds) <: Integer` because `JSON.parse("[1,2]")` results in `Any[1,2]` instead of `Int[1,2]`
        return init(i, baseline_cyc_bounds)
    elseif size_bcb == (i.num_fluo_wells, i.num_channels) &&
eltype(baseline_cyc_bounds) <: AbstractVector ## final format of `baseline_cyc_bounds`
        return baseline_cyc_bounds
    end
    throw(ArgumentError("`baseline_cyc_bounds` is not in the right format"))
end ## check_baseline_cyc_bounds()


## baseline estimation parameters
kwargs_bl(i ::AmpInput) =
    Dict{Symbol,Any}(
        min_reliable_cyc    => i.min_reliable_cyc,
        bl_method           => i.bl_method,
        bl_fallback_func    => i.bl_fallback_func)


## baseline estimation parameters
kwargs_quant(i ::AmpInput) =
    Dict{Symbol,Any}(
        cq_method           => i.cq_method)
