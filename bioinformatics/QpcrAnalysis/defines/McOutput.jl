#===============================================================================

    McOutput.jl

    containers for output from melting curve analysis

    Author: Tom Price
    Date:   July 2019

===============================================================================#


abstract type McOutput end

struct McLongOutput <: McOutput
    channel_nums                ::Vector{Int}
    fluo_well_nums              ::Vector{Int}
    # raw_data                    ::DataArray{Float_T,3}
    raw_data                    ::Array{Float_T,3}
    # background_subtracted_data  ::DataArray{Float_T,3}
    background_subtracted_data  ::Array{Float_T,3}
    k4dcv                       ::K4Deconv
    # deconvoluted_data           ::DataArray{Float_T,3}
    deconvoluted_data           ::Array{Float_T,3}
    norm_data                   ::OrderedDict{Symbol,Dict{Int,Vector{Float_T}}}
    norm_well_nums              ::Vector{Int}
    calibrated_data             ::Array{Float_T,3}
    peak_output                 ::Array{McPeakLongOutput,2} # dim1 is well and dim2 is channel
    # tf_bychwl                   ::OrderedDict{Int,Vector{OrderedDict{String,Vector{Float_T}}}}
end

## this type not necessary because `output_dict` in mc_analysis()
## can be constructed directly from `mc_matrix`:
# abstract type McShortOutput <: McOutput end
