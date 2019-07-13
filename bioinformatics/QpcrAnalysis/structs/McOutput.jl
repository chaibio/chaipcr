#==============================================================================================

    McOutput.jl

    containers for output from melting curve analysis

    Author: Tom Price
    Date:   July 2019

==============================================================================================#


abstract type McOutput end

struct McLongOutput <: McOutput
    channel_nums            ::Vector{Int}
    fluo_well_nums          ::Vector{Int}
    raw_date                ::DataArray{Float_T,3}
    background_subtracted   ::DataArray{Float_T,3}
    k4dcv                   ::K4Deconv
    deconvoluted            ::DataArray{Float_T,3}
    normalizable            ::OrderedDict{Symbol,Dict{Int,Vector{Float_T}}}
    norm_well_nums          ::Vector{Int}
    calibrated              ::Array{Float_T,3}
    peak_output_array       ::Array{McPeakLongOutput} # dim1 is well and dim2 is channel
    # tf_bychwl               ::OrderedDict{Int,Vector{OrderedDict{String,Vector{Float_T}}}}
end

## this type not necessary because `output_dict` in mc_analysis()
## can be constructed directly from `mc_bychannelwell`
# abstract type McShortOutput <: McOutput end
