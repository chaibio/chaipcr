## constants.jl
#
## Author: Tom Price
## Date: Dec 2018
#
## header file for QpcrAnalysis.jl module
## defines constants used at various places in the module

import DataStructures.OrderedDict
import JLD


## output format
const JSON_DIGITS = 6 ## number of decimal points for floats in JSON output

## used in supsmu.jl
const libsupsmu = "$LOAD_FROM_DIR/_supsmu.so"

## used in optical_test_single_channel.jl
# const BASELINE_STEP_ID = 12
# const EXCITATION_STEP_ID = 13
const MIN_EXCITATION_FLUORESCENCE = 5120
const MIN_EXCITATION_FLUORESCENCE_MULTIPLE = 3
const MAX_EXCITATION = 384000

## channel descriptors
## used in optical_test_dual_channel.jl
const CHANNELS = [1, 2]
const CHANNEL_IS = 1:length(CHANNELS)
# const CALIB_SYMBOLS_FAM_HEX = Symbol.(map(channel -> "channel_$channel", CHANNELS))
const SYMBOLS_FAM_HEX = [:FAM, :HEX]
# const OLD_CALIB_SYMBOLS = [:baseline; :water; CALIB_SYMBOLS_FAM_HEX]
const NEW_CALIB_SYMBOLS = [:baseline; :water; SYMBOLS_FAM_HEX]

## bounds of signal-to-noise ratio (SNR)
## used in optical_test_dual_channel.jl
const SNR_FAM_CH1_MIN = 0.75
const SNR_FAM_CH2_MAX = 1
const SNR_HEX_CH1_MAX = 0.50
const SNR_HEX_CH2_MIN = 0.88

## signal-to-noise ratio discriminant functions for each well
## used in optical_test_dual_channel.jl
dscrmnt_snr_fam(snr_2chs) = [snr_2chs[1] > SNR_FAM_CH1_MIN, snr_2chs[2] < SNR_FAM_CH2_MAX]
dscrmnt_snr_hex(snr_2chs) = [snr_2chs[1] < SNR_HEX_CH1_MAX, snr_2chs[2] > SNR_HEX_CH2_MIN]
const dscrmnts_snr = OrderedDict(map(1:2) do i
    SYMBOLS_FAM_HEX[i] => [dscrmnt_snr_fam, dscrmnt_snr_hex][i]
end) ## do i

## fluo values: channel 1, channel 2
## used in optical_test_dual_channel.jl
const WATER_MAX = [32000, 5000]
const WATER_MIN = [1000, -1000]

## used in thermal_performance_diagnostic.jl
const deltaTSetPoint = 1
const highTemperature = 95
const lowTemperature = 50
## xqrm
const HIGH_TEMP_mDELTA = highTemperature - deltaTSetPoint
const LOW_TEMP_pDELTA = lowTemperature + deltaTSetPoint
const MIN_AVG_RAMP_RATE = 2         ## °C/s
const MAX_TOTAL_TIME = 22.5e3       ## ms
const MAX_BLOCK_DELTA = 2           ## °C
const MIN_HEATING_RATE = 1          ## °C/s
const MAX_TIME_TO_HEAT = 90e3       ## ms