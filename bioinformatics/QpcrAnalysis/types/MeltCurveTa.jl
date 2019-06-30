## MeltCurveTa.jl
##
## Struct and methods used in meltcrv.jl
##
## Author: Tom Price
## Date:   June 2019


struct MeltCurveTa ## `Tm and area` - Ta
    mc              ::Array{Float_T,2}
    Ta_fltd         ::Array{Float_T,2}
    mc_denser       ::Array{Float_T,2}
    ns_range_mid    ::Float_T
    sn_dict         ::Dict{Symbol,Array{Float_T,2}}
    Ta_raw          ::Array{Float_T,2}
    Ta_reported     ::Symbol
end


## Constructor method

const EMPTY_mc      = zeros(1,3)[1:0,:]
const EMPTY_Ta      = zeros(1,2)[1:0,:]
const EMPTY_sn_dict = Dict(:tmprtrs => EMPTY_Ta, :fluos => EMPTY_Ta)

MeltCurveTa(;
    mc              ::Array{Float_T,2}              = EMPTY_mc
    Ta_fltd         ::Array{Float_T,2}              = EMPTY_Ta
    mc_denser       ::Array{Float_T,2}              = EMPTY_mc
    ns_range_mid    ::Float_T                       = NaN
    sn_dict         ::Dict{Symbol,Array{Float_T,2}} = EMPTY_sn_dict
    Ta_raw          ::Array{Float_T,2}              = EMPTY_mc
    Ta_reported     ::Symbol                        = :No
) =
    MeltCurveTa(mc, Ta_fltd, mc_denser, ns_range_mid, sn_dict, Ta_raw, Ta_reported)
