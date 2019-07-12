#==============================================================================================

    AmpInput.jl

    struct of data and all analysis parameters
    to be passed to amp_analysis() in amplification.jl

    the constructor is intended as the only interface
    to the amplification analysis and the only place
    where argument defaults are applied

    Author: Tom Price
    Date:   July 2019

==============================================================================================#

import DataStructures.OrderedDict
import Ipopt: IpoptSolver #, NLoptSolver


#==============================================================================================
    enums >>
==============================================================================================#

@enum CqMethod cp_dr1 cp_dr2 Cy0 ct max_eff
CqMethod(m ::String) = CqMethod(findfirst(map(string, instances(CqMethod)), m) - 1)

@enum AmpOutputOption long short cq_fluo
AmpOutputOption(option ::OutputFormat) =
    option == full_output ? long : short


#==============================================================================================
    constants >>
==============================================================================================#


## default for calibration
const DEFAULT_AMP_DCV               = true

## default values for baseline model
const DEFAULT_AMP_MODEL             = SFCModel
const DEFAULT_AMP_BL_METHOD         = l4_enl
const DEFAULT_AMP_FALLBACK_FUNC     = median
const DEFAULT_AMP_MIN_RELIABLE_CYC  = 5 ## >= 1
const DEFAULT_AMP_BL_CYC_BOUNDS     = Vector{Int}()

## defaults for quantification model
const DEFAULT_AMP_QUANT_METHOD      = l4_enl
const DEFAULT_AMP_DENSER_FACTOR     = 3                 ## must be an integer
const DEFAULT_AMP_CQ_METHOD         = Cy0
const DEFAULT_AMP_CT_FLUOS          = Vector{Float_T}() ## \ NB these defaults
const DEFAULT_AMP_CT_FLUO           = NaN               ## / cannot be overridden

## default for set_qt_fluos!()
const DEFAULT_AMP_QT_PROB           = 0.9

## defaults for report_cq!()
## note for default scaled_max_dr1_lb:
## 'look like real amplification, scaled_max_dr1 0.00894855, ip223, exp. 75, well A7, channel 2`
const DEFAULT_AMP_BEFORE_128X       = false
const DEFAULT_AMP_MAX_BSF_LB        = 4356              ## \
const DEFAULT_AMP_MAX_DR1_LB        = 472               ## | must be integers
const DEFAULT_AMP_MAX_DR2_LB        = 41                ## /
const DEFAULT_AMP_SCALED_MAX_BSF_LB = 0.086
const DEFAULT_AMP_SCALED_MAX_DR1_LB = 0.0089
const DEFAULT_AMP_SCALED_MAX_DR2_LB = 0.000689

## defaults for process_ad()
const DEFAULT_AMP_CYCS              = 0
const DEFAULT_AMP_CTRL_WELL_DICT    = CTRL_WELL_DICT
const DEFAULT_AMP_CLUSTER_METHOD    = k_means_medoids
const DEFAULT_AMP_NORM_L            = 2
const DEFAULT_AMP_DEFAULT_ENCGR     = DEFAULT_encgr
const DEFAULT_AMP_CATEG_WELL_VEC    = CATEG_WELL_VEC


#==============================================================================================
    struct >>
==============================================================================================#


struct AmpInput{F <: Real, C <: Real, M <: AmpModel}
    ## input data
    raw_data                ::RawFluo{F}
    num_cycs                ::Int
    num_fluo_wells          ::Int
    num_channels            ::Int
    cyc_nums                ::Vector{Int}
    fluo_well_nums          ::Vector{Int}
    channel_nums            ::Vector{Int}
    calibration_data        ::CalibrationData{C}
    ## solver
    solver                  ::IpoptSolver
    ipopt_print2file_prefix ::String
    ## calibration parameters
    dcv                     ::Bool
    ## amplification model
    amp_model               ::Type{M}
    ## output format parameters
    # out_sr_dict             ::Bool
    amp_output              ::AmpOutputOption
    amp_model_results       ::Type{<: AmpModelResults}  ## set by amp_output
    reporting               ::Function
    ## keyword arguments >>
    ## SFC model fitting parameters
    SFC_model_defs          ::OrderedDict{SFCModelName, SFCModelDef}
    bl_method               ::SFCModelName
    bl_fallback_func        ::Function
    min_reliable_cyc        ::Int
    baseline_cyc_bounds     ::Union{Vector,Array{Vector,2}}
    quant_method            ::SFCModelName
    denser_factor           ::Int
    cq_method               ::CqMethod
    ## argument for set_qt_fluos!()
    qt_prob                 ::Float_T
    ## arguments for report_cq!()
    before_128x             ::Bool
    max_bsf_lb              ::Int
    max_dr1_lb              ::Int
    max_dr2_lb              ::Int
    scaled_max_bsf_lb       ::Float_T
    scaled_max_dr1_lb       ::Float_T
    scaled_max_dr2_lb       ::Float_T
    ## arguments for process_ad()
    ctrl_well_dict          ::OrderedDict{Vector{Int},Vector{Int}}
    ## ...
end


#==============================================================================================
    method >>
==============================================================================================#


## constructor = interface to amp_analysis()
AmpInput{F <: Real, C <: Real, M <: AmpModel}(
    raw_data                ::RawFluo{F},
    num_cycs                ::Integer,
    num_fluo_wells          ::Integer,
    num_channels            ::Integer,
    cyc_nums                ::Vector{Int},
    fluo_well_nums          ::Vector{Int},
    channel_nums            ::Vector{Int},
    calibration_data        ::CalibrationData{C},
    solver                  ::IpoptSolver,
    ipopt_print2file_prefix ::AbstractString,
    dcv                     ::Bool,
    amp_model               ::Type{M},
    # out_sr_dict             ::Bool,
    amp_output              ::AmpOutputOption,
    reporting               ::Function;
    ## SFC model fitting parameters    
    SFC_model_defs          ::OrderedDict{SFCModelName, SFCModelDef}
                                                = SFC_MDs,
    bl_method               ::SFCModelName      = DEFAULT_AMP_BL_METHOD,
    bl_fallback_func        ::Function          = DEFAULT_AMP_FALLBACK_FUNC,
    min_reliable_cyc        ::Integer           = DEFAULT_AMP_MIN_RELIABLE_CYC,
    baseline_cyc_bounds     ::Union{AbstractVector,AbstractArray}
                                                = DEFAULT_AMP_BASELINE_CYC_BOUNDS,
    quant_method            ::SFCModelName      = DEFAULT_AMP_QUANT_METHOD,
    denser_factor           ::Int               = DEFAULT_AMP_DENSER_FACTOR,
    cq_method               ::CqMethod          = DEFAULT_AMP_CQ_METHOD,
    ## argument for set_qt_fluos!()
    qt_prob                 ::AbstractFloat     = DEFAULT_AMP_QT_PROB,
    ## arguments for report_cq!()
    before_128x             ::Bool              = DEFAULT_AMP_BEFORE_128X,
    max_bsf_lb              ::Integer           = DEFAULT_AMP_MAX_BSF_LB,
    max_dr1_lb              ::Integer           = DEFAULT_AMP_MAX_DR1_LB,
    max_dr2_lb              ::Integer           = DEFAULT_AMP_MAX_DR2_LB,
    scaled_max_bsf_lb       ::AbstractFloat     = DEFAULT_AMP_SCALED_MAX_BSF_LB,
    scaled_max_dr1_lb       ::AbstractFloat     = DEFAULT_AMP_SCALED_MAX_DR1_LB,
    scaled_max_dr2_lb       ::AbstractFloat     = DEFAULT_AMP_SCALED_MAX_DR2_LB,
    ## arguments for process_ad()
    ctrl_well_dict          ::OrderedDict{Vector{Int},Vector{Int}}
                                                = DEFAULT_AMP_CTRL_WELL_DICT,
) =
    AmpInput(
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
        amp_output == long ? AmpLongModelResults : AmpShortModelResults,
        reporting,
        SFC_model_defs,
        bl_method,
        bl_fallback_func,
        min_reliable_cyc,
        baseline_cyc_bounds,
        cq_method,
        denser_factor,
        qt_prob,
        before_128x,
        max_bsf_lb,
        max_dr1_lb,
        max_dr2_lb,
        scaled_max_dr1_lb,
        scaled_max_dr2_lb,
        scaled_max_bsf_lb,
        ctrl_well_dict,
    )


#==============================================================================================
    helper functions >>
==============================================================================================#


amp_init(i ::AmpInput, x...) = fill(x..., i.num_fluo_wells, i.num_channels)

## baseline estimation parameters
# kwargs_bl(i ::AmpInput) =
#     Dict{Symbol,Any}(
#         :bl_method          => i.bl_method,
#         :bl_fallback_func   => i.bl_fallback_func,
#         :min_reliable_cyc   => i.min_reliable_cyc,
#     )

## quantitation parameters
# kwargs_quant(i ::AmpInput) =
#     Dict{Symbol,Any}(
#         :cq_method          => i.cq_method,
#         :denser_factor      => i.denser_factor,
#     )

## arguments for process_ad()
kwargs_ad(i ::AmpInput) =
    Dict{Symbol,Any}(
        :ctrl_well_dict     => i.ctrl_well_dict,
        # :cluster_method     => i.cluster_method,
        # :norm_l             => i.norm_l,
        # :encgr              => i.encgr,
        # :categ_well_vec     => i.categ_well_vec
    )

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
