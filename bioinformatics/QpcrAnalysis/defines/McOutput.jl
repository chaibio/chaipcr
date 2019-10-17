#===============================================================================

    McOutput.jl

    containers for output from melting curve analysis

    Author: Tom Price
    Date:   July 2019

===============================================================================#

import StaticArrays: SVector, SArray


abstract type McOutput end

struct McLongOutput <: McOutput
    wells                       ::SVector{W,Symbol} where {W}
    channels                    ::SVector{C,Int_T} where {C}
    raw_data                    ::Array{<: Real,3}
    background_subtracted_data  ::Array{<: Real,3}
    k_deconv                    ::DeconvolutionMatrices
    deconvoluted_data           ::Array{Float_T,3}
    norm_data                   ::SArray{S,<: Real,3} where {S}
    norm_wells                  ::SVector{V,Symbol} where {V}
    calibrated_data             ::Array{Float_T,3}
    peak_output                 ::Array{McPeakOutput,2} ## dim1 is well and dim2 is channel
    # tf_bychwl                   ::OrderedDict{Int_T,Vector{OrderedDict{String,Vector{Float_T}}}}
end

## the following type not necessary because `output_dict` in mc_analysis()
## can be constructed directly from `mc_matrix`:
# abstract type McShortOutput <: McOutput end
