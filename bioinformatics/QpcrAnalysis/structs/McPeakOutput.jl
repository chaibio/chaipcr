#==============================================================================================

    McPeakOutput.jl

    melting curve analysis output struct
    for a single channel/well
-
    Author: Tom Price
    Date:   June 2019

==============================================================================================#


#==============================================================================================
    constants >>
==============================================================================================#


const EMPTY_data    = zeros(Float_T, 1,3)[1:0,:]
const EMPTY_peaks   = zeros(Float_T, 1,2)[1:0,:]
const EMPTY_sn      = Dict(:summit => EMPTY_peaks, :nadir => EMPTY_peaks)


#==============================================================================================
    structs >>
==============================================================================================#


abstract type McPeakOutput end


struct McPeakLongOutput <: McPeakOutput
    observed_data       ::Array{Float_T,2} ## needs to be typed
    peaks_filtered      ::Array{Float_T,2} ## needs to be typed
    smoothed_data       ::Array{Float_T,2} ## needs to be typed
    negderiv_midrange   ::Float_T
    extrema             ::Dict{Symbol,Array{Float_T,2}}
    peaks_raw           ::Array{Float_T,2} ## needs to be typed
    peaks_reported      ::Bool
end


struct McPeakShortOutput <: McPeakOutput
    observed_data       ::Array{Float_T,2} ## needs to be typed
    peaks_filtered      ::Array{Float_T,2} ## needs to be typed
end


#==============================================================================================
    constructors >>
==============================================================================================#


McPeakOutput(
    ::Type{McPeakLongOutput};
    observed_data       ::Array{Float_T,2}              = EMPTY_data,
    peaks_filtered      ::Array{Float_T,2}              = EMPTY_peaks,
    smoothed_data       ::Array{Float_T,2}              = EMPTY_data,
    negderiv_midrange   ::Float_T                       = NaN,
    extremes            ::Dict{Symbol,Array{Float_T,2}} = EMPTY_sn,
    peaks_raw           ::Array{Float_T,2}              = EMPTY_peaks,
    peaks_reported      ::Bool                          = false,
) =
    McPeakFullOutput(
        observed_data,
        peaks_filtered,
        smoothed_data,
        negderiv_midrange,
        extremes,
        peaks_raw,
        peaks_reported)


McPeakOutput(
    ::Type{McPeakShortOutput};
    observed_data       ::Array{Float_T,2}              = EMPTY_data,
    peaks_filtered      ::Array{Float_T,2}              = EMPTY_peaks,
) =
    McPeakShortOutput(
        observed_data,
        peaks_filtered)


## helper function >>

peak_output_format(out_format ::OutputFormat) =
    out_format == full_output ?
        McPeakLongOutput :
        McPeakShortOutput
