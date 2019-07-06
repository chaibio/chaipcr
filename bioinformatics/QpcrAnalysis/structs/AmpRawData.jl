## AmpRawData.jl
##
## raw ammplification data struct
##
## Author: Tom Price
## Date:   July 2019


abstract type AbstractAmpRawData end

struct AmpRawData{F <: Real} <: AbstractAmpRawData
    raw_data ::Array{F,3}
end
