# types_for_calibration.jl
#
# Author: Tom Price
# Date: Dec 2018

# type for K matrix
# used in deconv.jl
type K4Deconv
    k_s ::AbstractArray
    k_inv_vec ::AbstractArray
    inv_note ::String
end

# perform deconvolution and adjustment of well-to-well variation on calibration experiment 1
# using the k matrix `wva_data` made from calibration experiment 2
# used in calib.jl
type CalibCalibOutput
    ary2dcv_1 ::Array{AbstractFloat,3}
    mw_ary3_1 ::Array{AbstractFloat,3}
    k4dcv_2 ::K4Deconv
    dcvd_ary3_1 ::Array{AbstractFloat,3}
    wva_data_2 ::OrderedDict{String,OrderedDict{Int,AbstractVector}}
    dcv_aw_ary3_1 ::Array{AbstractFloat,3}
end

# used in adj_w2wvaf.jl
struct Ccsc # channels_check_subset_composite
    set ::Vector # channels
    description ::String
end

