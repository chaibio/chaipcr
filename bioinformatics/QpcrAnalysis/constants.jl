# constants.jl
#
# Author: Tom Price
# Date: Dec 2018
#
# header file for QpcrAnalysis.jl module
# defines all constants used anywhere in the module

import JLD.load


# output format
const JSON_DIGITS = 6 # number of decimal points for floats in JSON output

# set default calibration experiment (legacy)
const calib_info_AIR = 0

# scaling factors
# used in calib.jl
const SCALING_FACTOR_deconv_vec = [1.0, 4.2] # used: [1, oneof(1, 2, 3.5, 8, 7, 5.6, 4.2)]
const SCALING_FACTOR_adj_w2wvaf = 3.7 # used: 9e5, 1e5, 1.2e6, 3

# old pre-defined (predfd) step ids for calibration data
# used in adj_w2wvaf.jl
const oc_water_step_id_PREDFD = 2
const oc_signal_step_ids_PREDFD = OrderedDict(1=>4, 2=>4)

# mapping from factory to user dye data
# used in adj_w2wvaf.jl
# db_name_ = "20160406_chaipcr"
const PRESET_calib_ids = OrderedDict(
    "water" => 114,
    "signal" => OrderedDict("FAM"=>115, "HEX"=>116, "JOE"=>117)
)
const DYE2CHST = OrderedDict( # mapping from dye to channel and step_id.
    "FAM" => OrderedDict("channel"=>1, "step_id"=>266),
    "HEX" => OrderedDict("channel"=>2, "step_id"=>268),
    "JOE" => OrderedDict("channel"=>2, "step_id"=>270)
)

# type used in adj_w2wvaf.jl
struct Ccsc # channels_check_subset_composite
    set ::Vector # channels
    description ::String
end

# process preset calibration data
# used in adj_w2wvaf.jl
const DYE2CHST_channels = Vector{Int}(unique(map(
    dye_dict -> dye_dict["channel"],
    values(DYE2CHST)
))) # change type from Any to Int (8e-6 to 13e-6 sec on PC)
const DYE2CHST_ccsc = Ccsc(DYE2CHST_channels, "all channels in the preset well-to-well variation data")
# 4 groups
const DEFAULT_encgr = Array{Int,2}(0, 0)
# const DEFAULT_encgr = [0 1 0 1; 0 0 1 1] # NTC, homo ch1, homo ch2, hetero
const DEFAULT_init_FACTORS = [1, 1, 1, 1] # sometimes "hetero" may not have very high end-point fluo
const DEFAULT_apg_LABELS = ["ntc", "homo_1", "homo_2", "hetero", "unclassified"] # [0 1 0 1; 0 0 1 1]
# const DEFAULT_apg_LABELS = ["hetero", "homo_2", "homo_1", "ntc", "unclassified"] # [1 0 1 0; 1 1 0 0]

# used in allelic_discrimination.jl
const CATEG_WELL_VEC = [
    ("rbbs_ary3",   Colon()),
    ("blsub_fluos", Colon()),
    ("d0",          Colon()),
    ("cq",          Colon())
]

## from allelic_discrimination.jl
#
## 3 groups without NTC
# const DEFAULT_egr = [1 0 1; 0 1 1] # homo ch1, homo ch2, hetero
# const DEFAULT_init_FACTORS = [1, 1, 1] # sometimes "hetero" may not have very high end-point fluo
# const DEFAULT_eg_LABELS = ["homo_a", "homo_b", "hetero", "unclassified"]
#
# const CTRL_WELL_VEC = fill(Vector{Int}(), length(DEFAULT_init_FACTORS)) # All empty. NTC, homo ch1, homo ch2, hetero
const CTRL_WELL_DICT = OrderedDict{Vector{Int},Vector{Int}}() # key is genotype (Vector{Int}), value is well numbers (Vector{Int})
## example
# const CTRL_WELL_DICT = OrderedDict(
#     [0, 0] => [1, 2], # NTC, well 1 and 2
#     [1, 0] => [3, 4], # homo ch1, well 3 and 4
#     [0, 1] => [5, 6], # homo ch2, well 5 and 6
#     [1, 1] => [7, 8]  # hetero, well 7 and 8
# )
## old approach
# const CTRL_WELL_DICT = DefaultOrderedDict(Vector{Int}, Vector{Int}, Vector{Int}())

# type and constants for K matrix
# used in deconv.jl
type K4Deconv
    k_s ::AbstractArray
    k_inv_vec ::AbstractArray
    inv_note ::String
end
const ARRAY_EMPTY = Array{Any}()
const K4DCV_EMPTY = K4Deconv(ARRAY_EMPTY, ARRAY_EMPTY, "")
const K4DCV = JLD.load("$LOAD_FROM_DIR/k4dcv_ip84_calib79n80n81_vec.jld")["k4dcv"] # sometimes crash REPL


# used in meltcurve.jl
const EMPTY_mc = zeros(1,3)[1:0,:]
const EMPTY_Ta = zeros(1,2)[1:0,:]
const EMPTY_mc_tm_pw_out = OrderedDict(
    "mc" => EMPTY_mc,
    "Ta_raw" => EMPTY_Ta,
    "Ta_fltd" => EMPTY_Ta
)

# used in meltcurve.jl
struct MeltCurveTF # temperature and fluorescence
    t_da_vec ::Vector{DataArray{Float64,1}}
    fluo_da ::DataArray{Float64,2}
end

# used in meltcurve.jl
struct MeltCurveTa # Tm and area
    mc ::Array{Float64,2}
    Ta_fltd ::Array{Float64,2}
    mc_denser ::Array{Float64,2}
    ns_range_mid ::Real
    sn_dict ::OrderedDict{String,Array{Float64,2}}
    Ta_raw ::Array{Float64,2}
    Ta_reported ::String
end

# used in meltcurve.jl
struct MeltCurveOutput
    mc_bychwl ::Matrix{MeltCurveTa} # dim1 is well and dim2 is channel
    channel_nums ::Vector{Int}
    fluo_well_nums ::Vector{Int}
    fr_ary3 ::Array{Float64,3}
    mw_ary3 ::Array{Float64,3}
    k4dcv ::K4Deconv
    fdcvd_ary3 ::Array{Float64,3}
    wva_data ::OrderedDict{String,OrderedDict{Int,Vector{Float64}}}
    wva_well_nums ::Vector{Int}
    faw_ary3 ::Array{Float64,3}
    tf_bychwl ::OrderedDict{Int,Vector{OrderedDict{String,Vector{Float64}}}}
end

# used in standard_curve.jl
abstract type Result end
immutable TargetResultEle <: Result
    target_id ::Int
    slope ::Float64
    offset ::Float64
    efficiency ::Float64
    r2 ::Float64
end
const EMPTY_TRE = TargetResultEle(0, fill(NaN, 4)...)
immutable GroupResultEle <: Result
    well ::Vector{Int}
    target_id ::Int
    cq_mean ::Float64
    cq_sd ::Float64
    qty_mean ::Float64
    qty_sd ::Float64
end
const EMPTY_GRE = GroupResultEle([], 0, fill(NaN, 4)...)

## used in optical_test_single_channel.jl
# const BASELINE_STEP_ID = 12
# const EXCITATION_STEP_ID = 13
const MIN_EXCITATION_FLUORESCENCE = 5120
const MIN_EXCITATION_FLUORESCENCE_MULTIPLE = 3
const MAX_EXCITATION = 384000

# channel descriptors
# used in optical_test_dual_channel.jl
const CHANNELS = [1, 2]
const CHANNEL_IS = 1:length(CHANNELS)
const CALIB_LABELS_FAM_HEX = map(channel -> "channel_$channel", CHANNELS)
const OLD_CALIB_LABELS = ["baseline"; "water"; CALIB_LABELS_FAM_HEX]
const NEW_CALIB_LABELS = ["baseline"; "water"; "FAM"; "HEX"]

# bounds of signal-to-noise ratio (SNR)
# used in optical_test_dual_channel.jl
const SNR_FAM_CH1_MIN = 0.75
const SNR_FAM_CH2_MAX = 1
const SNR_HEX_CH1_MAX = 0.50
const SNR_HEX_CH2_MIN = 0.88

# fluo values: channel 1, channel 2
# used in optical_test_dual_channel.jl
const WATER_MAX = [32000, 5000]
const WATER_MIN = [1000, -1000]

# constants used in thermal_consistency.jl
const MIN_FLUORESCENCE_VAL = 8e5
const MIN_TM_VAL = 77
const MAX_TM_VAL = 81
const MAX_DELTA_TM_VAL = 2
# used to be in `thermal_consistency`
stage_id = 4
# passed onto `mc_tm_pw`, different than default
qt_prob_flTm = 0.1
normd_qtv_ub = 0.9

# types used in thermal_consistency.jl
type TmCheck1w
    Tm ::Tuple{AbstractFloat,Bool}
    area ::AbstractFloat
end
type ThermalConsistencyOutput
    tm_check ::Vector{TmCheck1w}
    delta_Tm ::Tuple{AbstractFloat,Bool}
end

# used in thermal_performance_diagnostic.jl
const deltaTSetPoint = 1
const highTemperature = 95
const lowTemperature = 50
# xqrm
const HIGH_TEMP_mDELTA = highTemperature - deltaTSetPoint
const LOW_TEMP_pDELTA = lowTemperature + deltaTSetPoint
const MIN_AVG_RAMP_RATE = 2 # C/s
const MAX_TOTAL_TIME = 22.5e3 # ms
const MAX_BLOCK_DELTA = 2 # C
const MIN_HEATING_RATE = 1 # C/s
const MAX_TIME_TO_HEAT = 90e3 # MySql