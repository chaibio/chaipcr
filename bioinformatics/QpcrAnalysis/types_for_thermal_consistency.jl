## types_for_thermal_consistency.jl
#
## Author: Tom Price
## Date: Dec 2018
#
## types used in thermal_consistency.jl

type TmCheck1w
    Tm          ::Tuple{Float_T,Bool}
    area        ::Float_T
end

type ThermalConsistencyOutput
    tm_check    ::Vector{TmCheck1w}
    delta_Tm    ::Tuple{Float_T,Bool}
    valid       ::Bool
end
