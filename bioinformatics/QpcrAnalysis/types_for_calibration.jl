## types_for_calibration.jl
#
## data types for calibration experiments
#
## Author: Tom Price
## Date: Dec 2018

import DataStructures.OrderedDict

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

