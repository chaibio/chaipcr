#==============================================================================================

    RawData.jl

    struct containing 3D array of raw data

    Author: Tom Price
    Date:   July 2019

==============================================================================================#


abstract type AbstractRaw end

struct RawData{F <: Real} <: AbstractRaw
    data ::Array{F,3}
end
