#===============================

	MeltCurveRawData.jl

	currently unused:
	a DataFrame is preferred

	Author: Tom Price
	Date:   July 2019

================================#


# struct MeltCurveRawData{F} where {F <: Real}
#     temperature     ::Vector{Float_T}
#     fluorescence    ::Vector{F}
#     well            ::Vector{Int}
#     channel         ::Vector{Int}
# end

# ## constructor
# MeltCurveRawData(mc_data ::Associative) =
#     MeltCurveRawData(
#         mc_data[TEMPERATURE_KEY],
#         mc_data[FLUORESCENCE_VALUE_KEY],
#         mc_data[WELL_NUM_KEY],
#         mc_data[CHANNEL_KEY])
