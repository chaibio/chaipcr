#==============================================

    RawFluo.jl

    struct containing raw fluorescence data
    from amplification experiment

    Author: Tom Price
    Date:   July 2019

===============================================#

import DataArrays.DataArray

abstract type AbstractRawFluo end

struct RawFluo{F <: Real} <: AbstractRawFluo
    fluorescence ::DataArray{F,3}
end
