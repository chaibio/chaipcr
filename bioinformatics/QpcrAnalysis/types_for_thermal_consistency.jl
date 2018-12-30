# types_for_thermal_consistency.jl
#
# Author: Tom Price
# Date: Dec 2018
#
# types used in thermal_consistency.jl

type TmCheck1w
    Tm ::Tuple{AbstractFloat,Bool}
    area ::AbstractFloat
end

type ThermalConsistencyOutput
    tm_check ::Vector{TmCheck1w}
    delta_Tm ::Tuple{AbstractFloat,Bool}
    valid ::Bool
end