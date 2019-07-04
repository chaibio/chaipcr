## K4Deconv.jl
##
## type for K matrix
## used in deconv.jl
##
## Author: Tom Price
## Date:   June 2019

import JLD


type K4Deconv
    k_s             ::Array{Array{F,2},1} where F <: AbstractFloat
    k_inv_vec       ::Array{Array{G,2},1} where G <: AbstractFloat
    inv_note        ::String
end

## constants
const ARRAY_EMPTY = Array{Array{Float_T,2},1}(0)
const K4DCV = JLD.load("$LOAD_FROM_DIR/constants/k4dcv_ip84_calib79n80n81_vec.jld")["k4dcv"] ## sometimes crashes REPL

## Null constructor
K4Deconv() = K4Deconv(ARRAY_EMPTY, ARRAY_EMPTY, "")
