#===============================================================================

    melting_curve.jl

    parse data from request for melting curve analysis

    Author: Tom Price
    Date:   July 2019

===============================================================================#

import DataStructures.OrderedDict
import DataFrames.DataFrame
import Memento: debug, info



#===============================================================================
    field names >>
===============================================================================#

const MC_RAW_FIELDS = Dict(
    :temperature            => TEMPERATURE_KEY,
    :fluorescence           => FLUORESCENCE_VALUE_KEY,
    :well                   => WELL_NUM_KEY,
    :channel                => CHANNEL_KEY)
const MC_PEAK_ANALYSIS_KEYWORDS = Dict{Symbol,String}(
    :norm_negderiv_quantile => "qt_prob",
    :max_norm_negderiv      => "max_normd_qtv",
    :max_num_peaks          => "top_N")
const MC_TF_KEYS = [:temperature, :fluorescence]
const MC_OUTPUT_FIELDS = OrderedDict(
    :observed_data          => :melt_curve_data,
    :peaks_filtered         => :melt_curve_analysis)


#===============================================================================
    function definitions >>
===============================================================================#


## called by dispatch()
function act(
    ::Type{Val{meltcurve}},
    req_dict    ::Associative;
    out_format  ::OutputFormat = pre_json
)
    debug(logger, "at act(::Type{Val{meltcurve}})")
    #
    ## required data
    if !raw_data_in_req(req_dict)
        return fail(logger, ArgumentError(
            "no raw data for melting curve analysis in request")) |> out(out_format)
    end
    if !calibration_info_in_req(req_dict)
        return fail(logger, ArgumentError(
            "no calibration data in request")) |> out(out_format)
    end
    #
    ## parse data from request
    const mc_parsed_raw_data = mc_parse_raw_data(req_dict[RAW_DATA_KEY])
    const calibration_data = CalibrationData(req_dict[CALIBRATION_INFO_KEY])
    #
    ## parse analysis parameters from request
    const kwargs_pa = OrderedDict{Symbol,Any}(
        map(keys(MC_PEAK_ANALYSIS_KEYWORDS)) do key
            key => req_dict[MC_PEAK_ANALYSIS_KEYWORDS[key]]
        end) ## do key
    #
    ## create container for data and parameter values
    interface = McInput(
            mc_parsed_raw_data...,
            calibration_data;
            out_format = out_format,
            kwargs_pa...)
    #
    ## pass data and parameter values to mc_analysis()
    ## which will perform the analysis for the entire dataset
    const response = try
        mc_analysis(interface)
    catch err
        return fail(logger, err; bt = true) |> out(out_format)
    end ## try
    return response |> out(out_format)
end ## act(::Type{Val{meltcurve}})


#==============================================================================#


"Extract dimensions of raw melting curve data and format as a DataFrame."
function mc_parse_raw_data(raw_dict ::Associative)
    const mc_raw_df = DataFrame()
    foreach(keys(MC_RAW_FIELDS)) do key
        try
            mc_raw_df[key] = raw_dict[MC_RAW_FIELDS[key]]
        catch err
            if isa(err, ArgumentError)
                throw(ArgumentError("the format of the raw data is incorrect:" *
                    "each data field should have the same length"))
            else
                rethrow()
            end ## if
        end ## try
    end ## next key
    mc_raw_df[:well] = mc_raw_df[:well] |> mold(Symbol ∘ Int)
    const (wells, channels) =
        map([WELL_NUM_KEY, CHANNEL_KEY]) do key
            raw_dict[key] |> unique |> sort
        end
    const (num_wells, num_channels) =
        map(length, (wells, channels))
    return (
        mc_raw_df,
        num_wells,
        num_channels,
        wells |> mold(Symbol ∘ Int) |> SVector{num_wells,Symbol},
        channels |> SVector{num_channels,Int})
end ## mc_parse_raw_data()
