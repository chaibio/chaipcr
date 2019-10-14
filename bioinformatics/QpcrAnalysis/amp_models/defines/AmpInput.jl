#===============================================================================

    AmpInput.jl

    defines struct of data and all analysis parameters
    to be passed to amp_analysis() in amplification.jl

    the constructor is intended as the only interface
    to the amplification analysis and the only place
    where argument defaults are applied

    Author: Tom Price
    Date:   July 2019

===============================================================================#

import DataStructures.OrderedDict
import StaticArrays: SMatrix, SVector
import Ipopt: IpoptSolver #, NLoptSolver



#===============================================================================
    defaults >>
===============================================================================#

## defaults for solver
DEFAULT_AMP_SOLVER                      = IpoptSolver(print_level = 0, max_iter = 35)
const DEFAULT_AMP_SOLVER_PRINT_PREFIX   = ""

## default values for baseline model
const DEFAULT_AMP_MODEL_DEF_FUNC        = m -> SFC_MODEL_DEFS[m]
const DEFAULT_AMP_MODEL                 = SFCModel
const DEFAULT_AMP_BL_METHOD             = l4_enl
const DEFAULT_AMP_FALLBACK_FUNC         = median
const DEFAULT_AMP_MIN_RELIABLE_CYC      = Int_T(5)         ## >= 1
const DEFAULT_AMP_BL_CYC_BOUNDS         = Vector{Int_T}()
const DEFAULT_AMP_CQ_FLUO_METHOD        = cp_dr1

## defaults for quantification model
const DEFAULT_AMP_QUANT_METHOD          = l4_enl
const DEFAULT_AMP_DENSER_FACTOR         = Int_T(3)         ## must be an integer
const DEFAULT_AMP_CQ_METHOD             = Cy0

## default for set_qt_fluos!()
const DEFAULT_AMP_QT_PROB               = 0.9

## defaults for report_cq!()
## note for default scaled_max_dr1_lb:
## 'look like real amplification, scaled_max_dr1 0.00894855, ip223, exp. 75, well A7, channel 2`
const DEFAULT_AMP_BEFORE_128X           = false
const DEFAULT_AMP_MAX_BSF_LB            = Int_T(4356)      ## ⎫
const DEFAULT_AMP_MAX_DR1_LB            = Int_T(472)       ## ⎬ must be integers
const DEFAULT_AMP_MAX_DR2_LB            = Int_T(41)        ## ⎭
const DEFAULT_AMP_SCALED_MAX_BSF_LB     = 0.086
const DEFAULT_AMP_SCALED_MAX_DR1_LB     = 0.0089
const DEFAULT_AMP_SCALED_MAX_DR2_LB     = 0.000689

## defaults for process_ad()
## see AssignGenosResult.jl

## defaults for output
const DEFAULT_AMP_OUTPUT_FORMAT         = pre_json_output
const DEFAULT_AMP_OUTPUT_OPTION         = short
const DEFAULT_AMP_MODEL_OUTPUT_STRUCT   = AmpShortModelResults
DEFAULT_AMP_REPORTER                    = roundoff(JSON_DIGITS)



#===============================================================================
    Field definitions >>
===============================================================================#

## name, DataType, default value
const AMP_FIELD_DEFS = [
    ## data
    Field(:raw,                 RawData{<: Union{Int_T,Float_T}}),
    Field(:num_cycles,          Int_T),
    Field(:num_wells,           Int_T),
    Field(:num_channels,        Int_T),
    Field(:cycles,              SVector{N,Int_T} where {N}),
    Field(:wells,               SVector{W,Symbol} where {W}),
    Field(:channels,            SVector{C,Int_T} where {C}),
    Field(:calibration_data,    CalibrationData{<: NumberOfChannels, <: Union{Int_T,Float_T}}),

    ## calibration parameters
    Field(:calibration_args,    CalibrationParameters,      DEFAULT_CAL_ARGS),

    ## solver parameters
    Field(:solver,              IpoptSolver,                DEFAULT_AMP_SOLVER),
    Field(:ipopt_print_prefix,  String,                     DEFAULT_AMP_SOLVER_PRINT_PREFIX),

    ## amplification model parameters
    Field(:amp_model,           Type{<: AmpModel},          DEFAULT_AMP_MODEL),
    Field(:SFC_model_def_func,  Function,                   DEFAULT_AMP_MODEL_DEF_FUNC),
    Field(:bl_method,           SFCModelName,               DEFAULT_AMP_BL_METHOD),
    Field(:bl_fallback_func,    Function,                   DEFAULT_AMP_FALLBACK_FUNC),
    Field(:min_reliable_cyc,    Int_T,                        DEFAULT_AMP_MIN_RELIABLE_CYC,   "min_reliable_cyc"),
    Field(:baseline_cyc_bounds, Union{Vector,Array{Vector,2}},
                                                            DEFAULT_AMP_BL_CYC_BOUNDS,      "baseline_cyc_bounds"),
    Field(:quant_method,        SFCModelName,               DEFAULT_AMP_QUANT_METHOD),
    Field(:denser_factor,       Int_T,                        DEFAULT_AMP_DENSER_FACTOR),
    Field(:cq_method,           CqMethod,                   DEFAULT_AMP_CQ_METHOD),
    Field(:qt_prob,             Float_T,                    DEFAULT_AMP_QT_PROB),
    Field(:before_128x,         Bool,                       DEFAULT_AMP_BEFORE_128X),
    Field(:max_bsf_lb,          Int_T,                        DEFAULT_AMP_MAX_BSF_LB,         "min_fluomax"),
    Field(:max_dr1_lb,          Int_T,                        DEFAULT_AMP_MAX_DR1_LB,         "min_D1max"),
    Field(:max_dr2_lb,          Int_T,                        DEFAULT_AMP_MAX_DR2_LB,         "min_D2max"),
    Field(:scaled_max_bsf_lb,   Float_T,                    DEFAULT_AMP_SCALED_MAX_BSF_LB),
    Field(:scaled_max_dr1_lb,   Float_T,                    DEFAULT_AMP_SCALED_MAX_DR1_LB),
    Field(:scaled_max_dr2_lb,   Float_T,                    DEFAULT_AMP_SCALED_MAX_DR2_LB),

    ## allelic discrimination parameters
    Field(:categ_well_vec,      Vector{Pair{Symbol,Any}},   DEFAULT_AMP_CATEG_WELL_VEC),
    Field(:ctrl_well_dict,      OrderedDict{Vector{Int_T},Vector{Int_T}},
                                                            DEFAULT_AMP_CTRL_WELL_DICT),
    ## output format parameters
    Field(:out_format,          OutputFormat,               DEFAULT_AMP_OUTPUT_FORMAT),
    Field(:amp_output,          AmpOutputOption,            DEFAULT_AMP_OUTPUT_OPTION),
    Field(:amp_model_results,   Type{<: AmpModelResults},   DEFAULT_AMP_MODEL_OUTPUT_STRUCT),
    Field(:reporting,           Function,                   DEFAULT_AMP_REPORTER)]



#===============================================================================
    macro calls >>
===============================================================================#

## generate struct and constructor
SCHEMA = AMP_FIELD_DEFS
@make_struct_from_SCHEMA AmpInput Input
@make_constructor_from_SCHEMA AmpInput
