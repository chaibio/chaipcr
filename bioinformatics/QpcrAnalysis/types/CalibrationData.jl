## CalibrationData.jl
##
## raw calibration data struct
## issue: is Union{T,Void} or Nullable{T} preferred in Julia v0.62?
##
## Author: Tom Price
## Date:   June 2019

import DataStructures.OrderedDict


abstract type AbstractCalibrationData end

struct CalibrationData{F <: Real} <: AbstractCalibrationData
	water		::Vector{Vector{Union{F,Void}}}
	channel_1	::Vector{Vector{Union{F,Void}}}
	channel_2	::Vector{Vector{Union{F,Void}}}
end

## Constructor method

CalibrationData(calib ::Associative) =
	CalibrationData(
		data[WATER_KEY][FLUORESCENCE_VALUE_KEY],
		data[CHANNEL_KEY * "_1"][FLUORESCENCE_VALUE_KEY],
		data[CHANNEL_KEY * "_2"][FLUORESCENCE_VALUE_KEY])
