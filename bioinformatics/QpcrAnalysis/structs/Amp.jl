## Amp.jl
##
## main object in amplification.jl
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
    ## calibration parameters
    kwargs_cal              ::Dict{Symbol,Any}
    ## solver
    solver                  ::IpoptSolver
    ipopt_print2file_prefix ::String
    ## amplification model
    amp_model               ::AmpModel
    ## SFC model fitting parameters
    min_reliable_cyc        ::Int
    baseline_cyc_bounds     ::Vector{Int}
    cq_method               ::Symbol
    ctrl_well_dict          ::Dict{}
    ## arguments for report_cq!()
    max_bsf_lb              ::Int
    max_dr1_lb              ::Int
    max_dr2_lb              ::Int
    qt_prob_rc              ::Float_T
    before_128x             ::Bool
    scaled_max_dr1_lb       ::AbstractFloat
    scaled_max_dr2_lb       ::AbstractFloat
    scaled_max_bsf_lb       ::AbstractFloat
    ## results
    asrp_vec                ::Vector{AmpStepRampProperties}
    ## arguments for process_ad()
    kwargs_ad               ::Dict{Symbol,Any}
    ## output format
    out_sr_dict             ::Bool
    out_format              ::Symbol
    reporting               ::Function
end


## default for asrp_vec
const DEFAULT_AMP_CYC_NUMS          = Vector{Int}()

## default for calibration
const DEFAULT_AMP_DCV               = true

## defaults for baseline model
const DEFAULT_AMP_MODEL             = SFC
const DEFAULT_AMP_MODEL_NAME        = :l4_enl
const DEFAULT_AMP_MODEL_DEF         = SFC_MDs[DEFAULT_AMP_MODEL_NAME]

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

