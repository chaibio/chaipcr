#===============================================================================

    McInput.jl

    defines struct of data and all analysis parameters
    to be passed to mc_analysis() in melting_curve.jl

    the constructor is intended as the only interface
    to the melting curve analysis and the only place
    where argument defaults are applied

    Author: Tom Price
    Date:   July 2019

===============================================================================#

import DataStructures.OrderedDict
import StaticArrays: SVector
import DataFrames.DataFrame



#===============================================================================
    defaults >>
===============================================================================#

## defaults for mc_analysis()
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
const DEFAULT_MC_NEGDERIV_RANGE_LOW_QUANTILE    = 0.21
const DEFAULT_MC_MAX_NUM_CROSS_POINTS           = 10    ## Integer
const DEFAULT_MC_NOISE_FACTOR                   = 0.2
const DEFAULT_MC_NORM_NEGDERIV_QUANTILE         = 0.64
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
    Field definitions >>
===============================================================================#

## name, DataType, default value
const MC_FIELD_DEFS = [
    Field(:raw_df,                      DataFrame),
    Field(:num_wells,                   Integer),
    Field(:num_channels,                Integer),
    Field(:wells,                       AbstractVector{Symbol}),
    Field(:channels,                    AbstractVector{<: Integer}),
    Field(:calibration_data,            CalibrationData{<: NumberOfChannels, <: Union{Int_T,Float_T}}),
    Field(:calibration_args,            CalibrationParameters, DEFAULT_CAL_ARGS),
    Field(:max_temperature,             Union{Int_T,Float_T},    DEFAULT_MC_MAX_TEMPERATURE),
    Field(:temp_too_close_frac,         AbstractFloat,         DEFAULT_MC_TEMP_TOO_CLOSE_FRAC),
    Field(:temperature_bandwidth,       AbstractFloat,         DEFAULT_MC_TEMPERATURE_BANDWIDTH),
    Field(:auto_span_smooth,            Bool,                  DEFAULT_MC_AUTO_SPAN_SMOOTH),
    Field(:span_smooth_default,         AbstractFloat,         DEFAULT_MC_SPAN_SMOOTH_DEFAULT),
    Field(:span_smooth_factor,          AbstractFloat,         DEFAULT_MC_SPAN_SMOOTH_FACTOR),
    Field(:denser_factor,               Integer,               DEFAULT_MC_DENSER_FACTOR),
    Field(:smooth_fluo_spline,          Bool,                  DEFAULT_MC_SMOOTH_FLUO_SPLINE),
    Field(:peak_span_temperature,       AbstractFloat,         DEFAULT_MC_PEAK_SPAN_TEMPERATURE),
    Field(:negderiv_range_low_quantile, AbstractFloat,         DEFAULT_MC_NEGDERIV_RANGE_LOW_QUANTILE),
    Field(:max_num_cross_points,        Integer,               DEFAULT_MC_MAX_NUM_CROSS_POINTS),
    Field(:noise_factor,                AbstractFloat,         DEFAULT_MC_NOISE_FACTOR),
    Field(:norm_negderiv_quantile,      AbstractFloat,         DEFAULT_MC_NORM_NEGDERIV_QUANTILE, "qt_prob"),
    Field(:max_norm_negderiv,           AbstractFloat,         DEFAULT_MC_MAX_NORM_NEGDERIV, "max_normd_qtv"),
    Field(:max_num_peaks,               Integer,               DEFAULT_MC_MAX_NUM_PEAKS, "top_N"),
    Field(:min_normalized_area,         AbstractFloat,         DEFAULT_MC_MIN_NORMALIZED_AREA),
    Field(:jitter_constant,             AbstractFloat,         DEFAULT_MC_JITTER_CONSTANT),
    Field(:out_format,                  OutputFormat,          pre_json_output),
    Field(:reporting,                   Function,              roundoff(JSON_DIGITS))]



#===============================================================================
    macro calls >>
===============================================================================#

## generate struct and constructor
SCHEMA = MC_FIELD_DEFS
@make_struct_from_SCHEMA McInput Input
@make_constructor_from_SCHEMA McInput
