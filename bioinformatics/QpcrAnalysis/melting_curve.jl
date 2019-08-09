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



#===============================================================================
    function definitions >>
===============================================================================#

## called by dispatch()
function act(
    ::Type{Val{meltcurve}},
    req         ::Associative;
    out_format  ::OutputFormat = pre_json
)
    debug(logger, "at act(::Type{Val{meltcurve}})")
    #
    ## required fields
    @get_calibration_data_from_req(meltcurve)
    @parse_raw_data_from_req(meltcurve)
    #
    ## keyword arguments
    const kwargs = MC_FIELD_DEFS |>
        sift(req_key ∘ field(:key)) |>
        mold() do x
            x.name => req[x.key]
        end
    #
    ## create container for data and parameter values
    interface = McInput(
            parsed_raw_data...,
            calibration_data;
            out_format = out_format,
            kwargs...)
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
function parse_raw_data(
    ::Union{Type{Val{meltcurve}},Type{Val{thermal_consistency}}},
    raw_dict ::Associative
)
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
end ## parse_raw_data(::Type{Val{meltcurve}})
