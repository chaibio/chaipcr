# types_for_meltcurve.jl
#
# Author: Tom Price
# Date: Dec 2018

struct MeltCurveTF # temperature and fluorescence
    t_da_vec ::Vector{DataArray{Float64,1}}
    fluo_da ::DataArray{Float64,2}
end

struct MeltCurveTa # Tm and area
    mc ::Array{Float64,2}
    Ta_fltd ::Array{Float64,2}
    mc_denser ::Array{Float64,2}
    ns_range_mid ::Real
    sn_dict ::OrderedDict{String,Array{Float64,2}}
    Ta_raw ::Array{Float64,2}
    Ta_reported ::String
end

struct MeltCurveOutput
    mc_bychwl ::Matrix{MeltCurveTa} # dim1 is well and dim2 is channel
    channel_nums ::Vector{Int}
    fluo_well_nums ::Vector{Int}
    fr_ary3 ::Array{Float64,3}
    mw_ary3 ::Array{Float64,3}
    k4dcv ::K4Deconv
    fdcvd_ary3 ::Array{Float64,3}
    wva_data ::OrderedDict{String,OrderedDict{Int,Vector{Float64}}}
    wva_well_nums ::Vector{Int}
    faw_ary3 ::Array{Float64,3}
    tf_bychwl ::OrderedDict{Int,Vector{OrderedDict{String,Vector{Float64}}}}
end