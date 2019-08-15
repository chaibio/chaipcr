#===============================================================================

    RawData.jl

    struct containing 3D array of raw data
    parameterized on unit type

    Dimensions:
    1. Unit: `cycle` for amplification data (type Int)
       `temperature` for melting curve data (type Float_T).
    2. Well: enumerated type, maximum 16.
    3. Channel: 1 or 2.

    Author: Tom Price
    Date:   July 2019

===============================================================================#


abstract type AbstractRaw end

struct RawData{F <: Union{Int,Float_T}} <: AbstractRaw
    data ::Array{F,3}
end
