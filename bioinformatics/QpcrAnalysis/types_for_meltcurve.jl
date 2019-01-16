## types_for_meltcurve.jl
#
## data types for melting curve
## and temperature consistency experiments
#
## Author: Tom Price
## Date: Dec 2018

import DataArrays.DataArray

struct MeltCurveRawData
    temperature     ::Vector{Float64}
    fluorescence    ::Vector{Float64}
    channel         ::Vector{Int}
    well_num        ::Vector{Int}
end

struct MeltCurveTF # `temperature and fluorescence` - TF
    t_da_vec        ::DataArray{Float64,2}
    fluo_da         ::DataArray{Float64,2}
end

struct MeltCurveTa # `Tm and area` - Ta
    mc              ::Array{Float64,2}
    Ta_fltd         ::Array{Float64,2}
    mc_denser       ::Array{Float64,2}
    ns_range_mid    ::Real
    sn_dict         ::Dict{Symbol,Array{Float64,2}}
    Ta_raw          ::Array{Float64,2}
    Ta_reported     ::String
end

struct MeltCurveOutput
    mc_bychwl       ::Array{MeltCurveTa} # dim1 is well and dim2 is channel
    channel_nums    ::Vector{Int}
    fluo_well_nums  ::Vector{Int}
    fr_ary3         ::DataArray{Float64,3}
    mw_ary3         ::DataArray{Float64,3}
    k4dcv           ::K4Deconv
    fdcvd_ary3      ::DataArray{Float64,3}
    wva_data        ::OrderedDict{Symbol,Dict{Int,Vector{Float64}}}
    wva_well_nums   ::Vector{Int}
    faw_ary3        ::Array{Float64,3}
    # tf_bychwl     ::OrderedDict{Int,Vector{OrderedDict{String,Vector{Float64}}}}
end

struct Peak
    idx             ::Int
    Tm              ::Float64
    area            ::Float64
end

struct PeakIndices
    summit_heights  ::Vector{Float64}
    summit_idc      ::Vector{Int}
    nadir_idc       ::Vector{Int}
    len_summit_idc  ::Int
    len_nadir_idc   ::Int
    PeakIndices(h,s,n) = new(vcat(h,0), vcat(s,0), vcat(n,0), length(s), length(n))
end




#
