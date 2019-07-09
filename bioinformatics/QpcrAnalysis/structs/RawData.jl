#==============================================

    RawData.jl

    struct containing raw fluorescence data
    from amplification experiment

    Author: Tom Price
    Date:   July 2019

===============================================#

import DataArrays.DataArray

abstract type AbstractRawData end

struct RawData{F <: Real} <: AbstractRawData
    fluorescence ::DataArray{F,3}
end
