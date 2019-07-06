## CalibrationData.jl
##
## raw calibration data struct
## this could be used to supply well numbers
##
## Author: Tom Price
## Date:   June 2019

import DataStructures.OrderedDict


abstract type AbstractCalibrationData end

struct CalibrationData{C <: Real} <: AbstractCalibrationData
    water           ::Vector{Union{Vector{C},Void}}
    channel_1       ::Vector{Union{Vector{C},Void}}
    channel_2       ::Vector{Union{Vector{C},Void}}
    num_channels    ::Int
end

## constructor
function CalibrationData(calib ::Associative)
    const w  = calib[WATER_KEY][FLUORESCENCE_VALUE_KEY]
    const C  = typeof(w[1][1])
    const c1 = calib[CHANNEL_KEY * "_1"][FLUORESCENCE_VALUE_KEY]
    if length(c1) > 1 && thing(c1[2]) && haskey(calib, CHANNEL_KEY * "_2")
        const c2 = calib[CHANNEL_KEY * "_2"][FLUORESCENCE_VALUE_KEY]
        const n  = 2
    else
        const c2 = [nothing, nothing]
        const n  = 1
    end
    CalibrationData{C}(
        cast(cast(Union{C,Void}))(w),
        cast(cast(Union{C,Void}))(c1),
        cast(cast(Union{C,Void}))(c2),
        n)
end

## other method
num_wells(this ::CalibrationData{<: Real}) =
    [:water, Symbol(CHANNEL_KEY, "_", 1), Symbol(CHANNEL_KEY, "_", 2)] |>
        mold(f -> num_wells(getfield(this, f))) |>
        maximum
