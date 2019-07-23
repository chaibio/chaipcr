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
    ## parse data from request into Dict of keywords
    mc_kwargs = Dict{Symbol,Any}(:out_format => out_format)
    parse_req_dict!(meltcurve, mc_kwargs, req_dict)
    #
    ## create container for data and parameter values
    parsed_raw_mc_data = mc_kwargs[:parsed_raw_mc_data]
    calibration_data   = mc_kwargs[:calibration_data]
    mc_kwargs = delete_all!(mc_kwargs, [:parsed_raw_mc_data, :calibration_data])
    interface = McInput(
            parsed_raw_mc_data...,
            calibration_data;
            mc_kwargs...)
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


## methods for data acquisition from request:
## add/remove/modify methods as appropriate if the API changes >>

parse_req(
            ::Type{Val{meltcurve}},
            ::Type{Val{:raw_data}},
    key     ::AbstractString,
    value   ::Associative
) =
    :parsed_raw_mc_data =>
        try
            mc_parse_raw_data(value)
        catch err
            throw(ArgumentError("could not parse raw data for melting curve analysis"))
        end ## try

parse_req(
            ::Type{Val{meltcurve}},
            ::Type{Val{:qt_prob}},
    key     ::AbstractString,
    value   ::Real
) =
    :norm_negderiv_quantile => Float_T(value)

parse_req(
            ::Type{Val{meltcurve}},
            ::Type{Val{:max_normd_qtv}}, 
    key     ::AbstractString,
    value   ::Real
) =
    :max_norm_negderiv => Float_T(value)

parse_req(
            ::Type{Val{meltcurve}},
            ::Type{Val{:top_N}},
    key     ::AbstractString,
    value   ::Int
) =
    :max_num_peaks => Int(value)


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
