#===============================================================================

    K4Deconv.jl

    types for K matrices and their inverses
    used in deconvolution.jl

    Author: Tom Price
    Date:   June 2019

===============================================================================#

import JLD
import StaticArrays: SVector, SMatrix


type K4Deconv
    k_s             ::Vector{Matrix{Float_T}}
    k_inv_vec       ::Vector{Matrix{Float_T}}
    inv_note        ::String
end

type DeconvolutionMatrices
    k_s             ::Vector{SMatrix{C,C,Float_T} where {C}}
    k_inv_vec       ::Vector{SMatrix{C,C,Float_T} where {C}}
    inv_note        ::String
end

## constants
const K4DCV = JLD.load("$LOAD_FROM_DIR/defines/k4dcv_ip84_calib79n80n81_vec.jld")["k4dcv"] ## sometimes crashes REPL

## Null constructors
function K4Deconv()
    const empty_vector = Vector{Matrix{Float_T}}(0)
    K4Deconv(empty_vector, empty_vector, "")
end
