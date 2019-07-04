## MeltCurveOutput.jl
##
## Author: Tom Price
## Date:   July 2019


struct MeltCurveOutput
    mc_array                ::Array{MeltCurveTa} # dim1 is well and dim2 is channel
    channel_nums            ::Vector{Int}
    fluo_well_nums          ::Vector{Int}
    raw                     ::DataArray{Float_T,3}
    background_subtracted   ::DataArray{Float_T,3}
    k4dcv                   ::K4Deconv
    deconvoluted            ::DataArray{Float_T,3}
    normalizable            ::OrderedDict{Symbol,Dict{Int,Vector{Float_T}}}
    norm_well_nums          ::Vector{Int}
    calibrated              ::Array{Float_T,3}
    # tf_bychwl               ::OrderedDict{Int,Vector{OrderedDict{String,Vector{Float_T}}}}
end
