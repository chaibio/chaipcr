#==============================================================================================

    RawData.jl

    struct containing 3D array of raw data

    Author: Tom Price
    Date:   July 2019

==============================================================================================#

# import DataArrays.DataArray

abstract type AbstractRaw end

struct RawData{F <: Real} <: AbstractRaw
    # data ::DataArray{F,3}
    data ::Array{F,3}
end
