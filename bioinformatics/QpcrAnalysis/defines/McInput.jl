#===============================================================================

    McInput.jl

    struct of data and all analysis parameters
    to be passed to mc_analysis() in melting_curve.jl

    the constructor is intended as the only interface
    to the  melting curve analysis and the only place
    where argument defaults are applied

    Author: Tom Price
    Date:   July 2019

===============================================================================#

import DataStructures.OrderedDict
import StaticArrays: SVector
import DataFrames.DataFrame



#===============================================================================
    constants >>
===============================================================================#

## defaults for mc_analysis()
const DEFAULT_MC_DCV                            = true
const DEFAULT_MC_AUTO_SPAN_SMOOTH               = false
const DEFAULT_MC_SPAN_SMOOTH_DEFAULT            = 0.015
const DEFAULT_MC_SPAN_SMOOTH_FACTOR             = 7.2
const DEFAULT_MC_MAX_TEMPERATURE                = 1000

## defaults for mc_peak_analysis()
const DEFAULT_MC_TEMP_TOO_CLOSE_FRAC            = 0.05
const DEFAULT_MC_TEMPERATURE_BANDWIDTH          = 1.0
const DEFAULT_MC_DENSER_FACTOR                  = 10    ## Integer
const DEFAULT_MC_SMOOTH_FLUO_SPLINE             = false
const DEFAULT_MC_PEAK_SPAN_TEMPERATURE          = 2.0
const DEFAULT_MC_NEGDERIVE_RANGE_LOW_QUANTILE   = 0.21
const DEFAULT_MC_MAX_NUM_CROSS_POINTS           = 10    ## Integer
const DEFAULT_MC_NOISE_FACTOR                   = 0.2
const DEFAULT_MC_NEGDERIV_QUANTILE              = 0.64
const DEFAULT_MC_MAX_NORM_NEGDERIV              = 0.8
# const DEFAULT_MC_TOP1_FROM_MAX_UB               = 1.0
const DEFAULT_MC_MAX_NUM_PEAKS                  = 4     ## Integer
const DEFAULT_MC_MIN_NORMALIZED_AREA            = 0.1

## default for mutate_dups()
const DEFAULT_MC_JITTER_CONSTANT                = 0.01

## defaults for mc_peak_analysis() overridden by mc_analysis()
# const OVERRIDDEN_DEFAULT_AUTO_SPAN_SMOOTH       = true
# const OVERRIDDEN_DEFAULT_MC_SPAN_SMOOTH_DEFAULT = 0.05
# const OVERRIDDEN_DEFAULT_MC_SPAN_SMOOTH_FACTOR  = 7.2



#===============================================================================
    struct >>
===============================================================================#

struct McInput <: Input
    ## raw data
    raw_df                      ::DataFrame
    ## data dimensions
    num_wells                   ::Int
    num_channels                ::Int
    wells                       ::SVector{W,Symbol} where {W}
    channels                    ::SVector{C,Int} where {C}
    #
    ## calibration data and parameters
    calibration                 ::CalibrationData{<: NumberOfChannels, <: Real}
    calibration_args            ::CalibrationParameters
    #
    ## melting curve analysis parameters
    max_temperature             ::Int
    temp_too_close_frac         ::Float_T
    temperature_bandwidth       ::Float_T
    auto_span_smooth            ::Bool
    span_smooth_default         ::Float_T
    span_smooth_factor          ::Float_T
    denser_factor               ::Int
    smooth_fluo_spline          ::Bool
    peak_span_temperature       ::Float_T
    # peak_shoulder               ::Float_T
    negderiv_range_low_quantile ::Float_T
    max_num_cross_points        ::Int
    noise_factor                ::Float_T
    norm_negderiv_quantile      ::Float_T
    max_norm_negderiv           ::Float_T
    # top1_from_max_ub            ::Float_T
    max_num_peaks               ::Int
    min_normalized_area         ::Float_T
    jitter_constant             ::Float_T
    #
    ## output parameters
    out_format                  ::OutputFormat
    reporting                   ::Function
end



#===============================================================================
    method >>
===============================================================================#

## constructor
McInput(
    ## data
    raw_df                      ::DataFrame,
    num_wells                   ::Integer,
    num_channels                ::Integer,
    wells                       ::AbstractVector{Symbol},
    channels                    ::AbstractVector{<: Integer},
    #
    ## calibration data
    calibration_data            ::CalibrationData{<: NumberOfChannels, <: Real};
    ## calibration parameters
    dcv                         ::Bool              = DEFAULT_MC_DCV,
    dye_in                      ::Symbol            = DEFAULT_CAL_DYE_IN,
    dyes_to_fill                ::AbstractVector    = DEFAULT_CAL_DYES_TO_FILL,
    subtract_water              ::Bool              = DEFAULT_NORM_SUBTRACT_WATER,
    k_method                    ::KMethod           = DEFAULT_DCV_K_METHOD,
    #
    ## melting curve analysis parameters
    ## unused parameter
    max_temperature             ::Real              = DEFAULT_MC_MAX_TEMPERATURE,
    ## fraction of median temperature interval below which datapoints are considered too close
    temp_too_close_frac         ::AbstractFloat     = DEFAULT_MC_TEMP_TOO_CLOSE_FRAC,
    ## parameters for smoothing -df/dt curve and if `smooth_fluo`, fluorescence curve too
    temperature_bandwidth       ::AbstractFloat     = DEFAULT_MC_TEMPERATURE_BANDWIDTH, ## fluorescence fluctuation with the temperature range of approximately `dyes_to_fill * 2` is considered for choosing `span_smooth`
    auto_span_smooth            ::Bool              = DEFAULT_MC_AUTO_SPAN_SMOOTH,
    span_smooth_default         ::AbstractFloat     = DEFAULT_MC_SPAN_SMOOTH_DEFAULT, ## unit: fraction of data points for smoothing
    span_smooth_factor          ::AbstractFloat     = DEFAULT_MC_SPAN_SMOOTH_FACTOR,
    ## get a denser temperature sequence to get fluorescence and -df/dt from it and fitted spline function
    denser_factor               ::Integer           = DEFAULT_MC_DENSER_FACTOR,
    smooth_fluo_spline          ::Bool              = DEFAULT_MC_SMOOTH_FLUO_SPLINE,
    ## identify peaks and calculate peak area
    peak_span_temperature       ::AbstractFloat     = DEFAULT_MC_PEAK_SPAN_TEMPERATURE, ## Within the smoothed -df/dt sequence spanning the temperature range of approximately `peak_span_temperature`, if the maximum -df/dt value equals that at the middle point of the sequence, identify this middle point as a peak summit. Similar to `span.peaks` in qpcR code. Combined with `peak_shoulder` (similar to `Tm.border` in qpcR code).
    # peak_shoulder               ::AbstractFloat = 1.0, ## 1/2 width of peak in temperature when calculating peak area  # consider changing from 1 to 2, or automatically determined (max and min d2)?
    ## criteria for filtering peaks
    negderiv_range_low_quantile ::AbstractFloat     = DEFAULT_MC_NEGDERIVE_RANGE_LOW_QUANTILE, ## designated quantile used to assess lower bound of the range considered for number of crossing points
    max_num_cross_points        ::Integer           = DEFAULT_MC_MAX_NUM_CROSS_POINTS, ## upper bound of number of data points crossing the mid range value (line parallel to x-axis) of smoothed -df/dt (`negderiv_smu`)
    noise_factor                ::AbstractFloat     = DEFAULT_MC_NOISE_FACTOR, ## `num_cross_points` must also <= `noisy_factor * len_raw`
    norm_negderiv_quantile      ::AbstractFloat     = DEFAULT_MC_NORM_NEGDERIV_QUANTILE, ## designated quantile for assessing normalized -df/dT values (range 0-1)
    max_norm_negderiv           ::AbstractFloat     = DEFAULT_MC_MAX_NORM_NEGDERIV, ## upper bound of normalized -df/dt values (range 0-1) at the designated quantile
    # top1_from_max_ub            ::AbstractFloat     = DEFAULT_MC_TOP1_FROM_MAX_UB, ## upper bound of temperature difference between top-1 Tm peak and maximum -df/dt
    max_num_peaks               ::Integer           = DEFAULT_MC_MAX_NUM_PEAKS, ## top number of peaks to report
    min_normalized_area         ::AbstractFloat     = DEFAULT_MC_MIN_NORMALIZED_AREA, ## smallest reportable peak as proportion of the area of the largest peak
    ## argument for mutate_dups()
    jitter_constant             ::AbstractFloat     = DEFAULT_MC_JITTER_CONSTANT,
    #
    ## output format parameters
    out_format                  ::OutputFormat      = pre_json_output,
    reporting                   ::Function          = roundoff(JSON_DIGITS), ## reporting function
) =
    McInput(
        raw_df,
        num_wells,
        num_channels,
        wells,
        channels,
        #
        calibration_data,
        CalibrationParameters(
            dcv,
            dye_in,
            dyes_to_fill,
            subtract_water,
            k_method),
        #
        max_temperature,
        temp_too_close_frac,
        temperature_bandwidth,
        auto_span_smooth,
        span_smooth_default,
        span_smooth_factor,
        denser_factor,
        smooth_fluo_spline,
        peak_span_temperature,
        # peak_shoulder
        negderiv_range_low_quantile,
        max_num_cross_points,
        noise_factor,
        norm_negderiv_quantile,
        max_norm_negderiv,
        # top1_from_max_ub,
        max_num_peaks,
        min_normalized_area,
        jitter_constant,
        #
        out_format,
        reporting)



#===============================================================================
    helper function >>
===============================================================================#

## parameters to be passed to mc_peak_analysis()
# kwargs_pa(i ::McInput) =
#     Dict{Symbol,Any}(
#         :temp_too_close_frac         => i.temp_too_close_frac,
#         :temperature_bandwidth       => i.temperature_bandwidth,
#         :auto_span_smooth            => i.auto_span_smooth,
#         :span_smooth_default         => i.span_smooth_default,
#         :span_smooth_factor          => i.span_smooth_factor,
#         :denser_factor               => i.denser_factor,
#         :smooth_fluo_spline          => i.smooth_fluo_spline,
#         :peak_span_temperature       => i.peak_span_temperature,
#         :negderiv_range_low_quantile => i.negderiv_range_low_quantile,
#         :max_num_cross_points        => i.max_num_cross_points,
#         :noise_factor                => i.noise_factor,
#         :norm_negderiv_quantile      => i.norm_negderiv_quantile,
#         :max_norm_negderiv           => i.max_norm_negderiv,
#         :max_num_peaks               => i.max_num_peaks,
#         :min_normalized_area         => i.min_normalized_area,
#         :jitter_constant             => i.jitter_constant)
    