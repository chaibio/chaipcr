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


#===============================================================================
    constructor requiring Input type >>
===============================================================================#

function K4Deconv()
    const empty_vector = Vector{Matrix{Float_T}}(0)
    K4Deconv(empty_vector, empty_vector, "")
end


function DeconvolutionMatrices(calibration ::CalibrationInput)
    const s = size(calibration.data.array)
    const w = s[1]
    const c = s[2]
    const v = calibration.args.k_method == well_proc_vec ? w : 1
    const empty_matrix = SMatrix{c,c,Float_T}(fill(NaN,c,c))
    DeconvolutionMatrices(
        SVector{v}(fill(empty_matrix,v)),
        SVector{w}(fill(empty_matrix,w)),
        "")
end



#===============================================================================
    constant >>
===============================================================================#

## NB loading this sometimes crashes REPL
const K4DCV = JLD.load("$LOAD_FROM_DIR/defines/k4dcv_ip84_calib79n80n81_vec.jld")["k4dcv"]
