#===============================================================================

    NumberOfChannels.jl

    abstract type defining number of data channels

    Author: Tom Price
    Date:   July 2019

===============================================================================#


abstract type NumberOfChannels                  end
abstract type SingleChannel <: NumberOfChannels end
abstract type DualChannel   <: NumberOfChannels end

count_channels(::Type{SingleChannel}) = 1
count_channels(::Type{DualChannel}) = 2