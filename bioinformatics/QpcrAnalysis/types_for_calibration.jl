## types_for_calibration.jl
#
## data types and constants for calibration experiments
#
## Author: Tom Price
## Date: Dec 2018

import DataStructures.OrderedDict
import JLD


## types

## type for K matric calculation
## used in deconv.jl
abstract type  WellProc         end
struct         WellProcMean     <: WellProc end
struct         WellProcVec      <: WellProc end

## type for K matrix
## used in deconv.jl
type K4Deconv
    k_s             ::Array{Array{F,2},1} where F <: AbstractFloat
    k_inv_vec       ::Array{Array{G,2},1} where G <: AbstractFloat
    inv_note        ::String
end

## perform deconvolution and adjustment of well-to-well variation on calibration experiment 1
## using the k matrix `wva_data` made from calibration experiment 2
## used in calib.jl

type CalibCalibOutput
    ary2dcv_1       ::Array{Float_T,3}
    mw_ary3_1       ::Array{Float_T,3}
    k4dcv_2         ::K4Deconv
    dcvd_ary3_1     ::Array{Float_T,3}
    wva_data_2      ::OrderedDict{Symbol,OrderedDict{Int,AbstractVector}}
    dcv_aw_ary3_1   ::Array{Float_T,3}
end

# used in adj_w2wvaf.jl
struct Ccsc # channels_check_subset_composite
    set             ::Vector # channels
    description     ::String
end


## constants

## set default calibration experiment (legacy)
const calib_info_AIR = 0

## scaling factors
## used in calib.jl
const SCALING_FACTOR_deconv_vec = [1.0, 4.2] ## used: [1, oneof(1, 2, 3.5, 8, 7, 5.6, 4.2)]
const SCALING_FACTOR_adj_w2wvaf = 3.7 ## used: 9e5, 1e5, 1.2e6, 3.0

## old pre-defined (predfd) step ids for calibration data
## used in adj_w2wvaf.jl
const oc_water_step_id_PREDFD = 2
const oc_signal_step_ids_PREDFD = OrderedDict(1 => 4, 2 => 4)

## mapping from factory to user dye data
## used in adj_w2wvaf.jl
## db_name_ = "20160406_chaipcr"
# const PRESET_calib_ids = OrderedDict(
#     "water" => 114,
#     "signal" => OrderedDict("FAM"=>115, "HEX"=>116, "JOE"=>117))
# const DYE2CHST = OrderedDict( ## mapping from dye to channel and step_id.
#     "FAM" => OrderedDict("channel"=>1, "step_id"=>266),
#     "HEX" => OrderedDict("channel"=>2, "step_id"=>268),
#     "JOE" => OrderedDict("channel"=>2, "step_id"=>270))
# const DYE2CHST_channels = Vector{Int}(unique(map(
#     dye_dict -> dye_dict["channel"],
#     values(DYE2CHST)
# ))) ## change type from Any to Int (8e-6 to 13e-6 sec on PC)
# const DYE2CHST_ccsc = Ccsc(DYE2CHST_channels, "all channels in the preset well-to-well variation data")

## process preset calibration data
## used in adj_w2wvaf.jl
## 4 groups
const DEFAULT_encgr = Array{Int,2}(0, 0)
## const DEFAULT_encgr = [0 1 0 1; 0 0 1 1] ## NTC, homo ch1, homo ch2, hetero
const DEFAULT_init_FACTORS = [1, 1, 1, 1] ## sometimes "hetero" may not have very high end-point fluo
const DEFAULT_apg_LABELS = ["ntc", "homo_1", "homo_2", "hetero", "unclassified"] ## [0 1 0 1; 0 0 1 1]
## const DEFAULT_apg_LABELS = ["hetero", "homo_2", "homo_1", "ntc", "unclassified"] ## [1 0 1 0; 1 1 0 0]

## constants used in deconv.jl
const ARRAY_EMPTY = Array{Array{Float_T,2},1}(0)
const K4DCV_EMPTY = K4Deconv(ARRAY_EMPTY, ARRAY_EMPTY, "")
const K4DCV = JLD.load("$LOAD_FROM_DIR/k4dcv_ip84_calib79n80n81_vec.jld")["k4dcv"] ## sometimes crash REPL
const INV_NOTE_PT2 =
    ": K matrix is singular, using `pinv` instead of `inv` to compute inverse matrix of K. " *
    "Deconvolution result may not be accurate. " *
    "This may be caused by using the same or a similar set of solutions in the steps for different dyes."

