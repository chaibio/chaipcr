## types_for_meltcurve.jl
#
## data types and constants for melting curve
## and temperature consistency experiments
#
## Author: Tom Price
## Date: Dec 2018

import DataArrays.DataArray

include("peak.jl")
include("peakindices.jl")


## types

struct MeltCurveRawData
    temperature     ::Vector{Float_T}
    fluorescence    ::Vector{Float_T}
    channel         ::Vector{Int}
    well_num        ::Vector{Int}
end

struct MeltCurveTF # `temperature and fluorescence` - TF
    t_da            ::DataArray{Float_T,2}
    fluo_da         ::DataArray{Float_T,2}
end

struct MeltCurveTa # `Tm and area` - Ta
    mc              ::Array{Float_T,2}
    Ta_fltd         ::Array{Float_T,2}
    mc_denser       ::Array{Float_T,2}
    ns_range_mid    ::Float_T
    sn_dict         ::Dict{Symbol,Array{Float_T,2}}
    Ta_raw          ::Array{Float_T,2}
    Ta_reported     ::Symbol
end

struct MeltCurveOutput
    mc_bychwl       ::Array{MeltCurveTa} # dim1 is well and dim2 is channel
    channel_nums    ::Vector{Int}
    fluo_well_nums  ::Vector{Int}
    fr_ary3         ::DataArray{Float_T,3}
    mw_ary3         ::DataArray{Float_T,3}
    k4dcv           ::K4Deconv
    fdcvd_ary3      ::DataArray{Float_T,3}
    wva_data        ::OrderedDict{Symbol,Dict{Int,Vector{Float_T}}}
    wva_well_nums   ::Vector{Int}
    faw_ary3        ::Array{Float_T,3}
    # tf_bychwl     ::OrderedDict{Int,Vector{OrderedDict{String,Vector{Float_T}}}}
end

struct Peak
    idx             ::Int
    Tm              ::Float_T
    area            ::Float_T
end


## types used in thermal_consistency.jl

type TmCheck1w
    Tm          ::Tuple{Float_T, Bool}
    area        ::Float_T
end

type ThermalConsistencyOutput
    tm_check    ::Vector{TmCheck1w}
    delta_Tm    ::Tuple{Float_T, Bool}
    valid       ::Bool
end


## constants

## used in meltcurve.jl
const MC_TM_PW_KEYWORDS = Dict{Symbol,String}(
    :qt_prob_flTm   => "qt_prob",
    :normd_qtv_ub   => "max_normd_qtv",
    :top_N          => "top_N")
const TF_KEYS = [:temperature, :fluorescence_value]
const EMPTY_mc = zeros(1,3)[1:0,:]
const EMPTY_Ta = zeros(1,2)[1:0,:]
const EMPTY_mc_tm_pw_out = MeltCurveTa(
    EMPTY_mc,                                   ## mc_raw
    EMPTY_Ta,                                   ## Ta_fltd
    EMPTY_mc,                                   ## mc_denser
    NaN,                                        ## ns_range_mid
    Dict(:tmprtrs=>EMPTY_Ta, :fluos=>EMPTY_Ta), ## sn_dict
    EMPTY_Ta,                                   ## Ta_raw
    ""                                          ## Ta_reported
)
const MC_OUT_FIELDS = OrderedDict(
    :mc      => :melt_curve_data,
    :Ta_fltd => :melt_curve_analysis)

## constants used in thermal_consistency.jl
const MIN_FLUORESCENCE_VAL = 8e5
const MIN_TM_VAL = 77
const MAX_TM_VAL = 81
const MAX_DELTA_TM_VAL = 2
## used to be in `thermal_consistency`
stage_id = 4
## passed onto `mc_tm_pw`, different than default
qt_prob_flTm = 0.1
normd_qtv_ub = 0.9


## null constructor method
# Peak(nothing) = Peak([])
