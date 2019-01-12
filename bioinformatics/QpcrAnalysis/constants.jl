# constants.jl
#
# Author: Tom Price
# Date: Dec 2018
#
# header file for QpcrAnalysis.jl module
# defines all constants used anywhere in the module

import DataStructures.OrderedDict
import JLD

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

# constants used in deconv.jl
const ARRAY_EMPTY = Array{Any}()
const K4DCV_EMPTY = K4Deconv(ARRAY_EMPTY, ARRAY_EMPTY, "")
const K4DCV = JLD.load("$LOAD_FROM_DIR/k4dcv_ip84_calib79n80n81_vec.jld")["k4dcv"] # sometimes crash REPL

# used in supsmu.jl
const libsupsmu = "$LOAD_FROM_DIR/_supsmu.so"

# used in meltcurve.jl
const EMPTY_mc = zeros(1,3)[1:0,:]
const EMPTY_Ta = zeros(1,2)[1:0,:]
const EMPTY_mc_tm_pw_out = MeltCurveTa(
    EMPTY_mc,                                   # mc_raw
    EMPTY_Ta,                                   # Ta_fltd
    EMPTY_mc,                                   # mc_denser
    NaN,                                        # ns_range_mid
    Dict(:tmprtrs=>EMPTY_Ta, :fluos=>EMPTY_Ta), # sn_dict
    EMPTY_Ta,                                   # Ta_raw
    ""                                          # Ta_reported
)
const MC_FIELDS = OrderedDict(
    :mc      => "melt_curve_data",
    :Ta_fltd => "melt_curve_analysis")

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
const SYMBOLS_FAM_HEX = [:FAM, :HEX]
const OLD_CALIB_LABELS = ["baseline"; "water"; CALIB_LABELS_FAM_HEX]
const NEW_CALIB_LABELS = ["baseline"; "water"; map(string,SYMBOLS_FAM_HEX)]

# bounds of signal-to-noise ratio (SNR)
# used in optical_test_dual_channel.jl
const SNR_FAM_CH1_MIN = 0.75
const SNR_FAM_CH2_MAX = 1
const SNR_HEX_CH1_MAX = 0.50
const SNR_HEX_CH2_MIN = 0.88

# signal-to-noise ratio discriminant functions for each well
# used in optical_test_dual_channel.jl
dscrmnt_snr_fam(snr_2chs) = [snr_2chs[1] > SNR_FAM_CH1_MIN, snr_2chs[2] < SNR_FAM_CH2_MAX]
dscrmnt_snr_hex(snr_2chs) = [snr_2chs[1] < SNR_HEX_CH1_MAX, snr_2chs[2] > SNR_HEX_CH2_MIN]
const dscrmnts_snr = OrderedDict(map(1:2) do i
    CALIB_LABELS_FAM_HEX[i] => [dscrmnt_snr_fam, dscrmnt_snr_hex][i]
end) # do i

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