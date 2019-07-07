## AmpRawData.jl
##
## raw ammplification data struct
##
## Author: Tom Price
## Date:   July 2019


abstract type AbstractAmpRawData end

struct AmpRawData{F <: Real} <: AbstractAmpRawData
    a ::Array{F,3}
end
