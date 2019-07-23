#===============================================================================

    McPeakOutput.jl

    melting curve analysis output struct
    for a single channel/well

    Author: Tom Price
    Date:   June 2019

===============================================================================#


#===============================================================================
    constants >>
===============================================================================#

const EMPTY_data    = zeros(Float_T, 1,3)[1:0,:]
const EMPTY_peaks   = zeros(Float_T, 1,2)[1:0,:]
const EMPTY_sn      = Dict(:summit => EMPTY_peaks, :nadir => EMPTY_peaks)



#===============================================================================
    Field definitions >>
===============================================================================#

const PEAKOUTPUT_FIELD_DEFS = [
    Field(:observed_data,         Array{Float_T,2},               EMPTY_data),
    Field(:peaks_filtered,        Array{Float_T,2},               EMPTY_peaks),
    Field(:smoothed_data,         Array{Float_T,2},               EMPTY_data),
    Field(:negderiv_midrange,     Float_T,                        NaN),
    Field(:extremes,              Dict{Symbol,Array{Float_T,2}},  EMPTY_sn),
    Field(:peaks_raw,             Array{Float_T,2},               EMPTY_peaks),
    Field(:peaks_reported,        Bool,                           false)]



#===============================================================================
    struct and constructor generation >>
===============================================================================#

abstract type McPeakOutput end

SCHEMA = PEAKOUTPUT_FIELD_DEFS
@make_struct_from_SCHEMA McPeakLongOutput McPeakOutput
@make_constructor_from_SCHEMA McPeakLongOutput

SCHEMA = PEAKOUTPUT_FIELD_DEFS[1:2]
@make_struct_from_SCHEMA McPeakShortOutput McPeakOutput
@make_constructor_from_SCHEMA McPeakShortOutput



#===============================================================================
    helper function >>
===============================================================================#

peak_output_format(out_format ::OutputFormat) =
    out_format == full_output ?
        McPeakLongOutput :
        McPeakShortOutput
