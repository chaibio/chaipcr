#==============================================================================================

    melting_curve.jl

    melting curve analysis

==============================================================================================#

import DataStructures.OrderedDict
import DataArrays.DataArray
import DataFrames.DataFrame
import Memento: debug, error


#==============================================================================================
    field names >>
==============================================================================================#


const MC_RAW_FIELDS = OrderedDict(
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


#==============================================================================================
    function definitions >>
==============================================================================================#


## called by dispatch()
function act(
    ::Type{Val{meltcurve}},
    req_dict    ::Associative;
    out_format  ::OutputFormat = pre_json
)
    debug(logger, "at act(::Type{Val{meltcurve}})")
    #
    ## calibration data is required    
    if !(haskey(req_dict,CALIBRATION_INFO_KEY) &&
        typeof(req_dict[CALIBRATION_INFO_KEY]) <: Associative)
            return fail(logger, ArgumentError(
                "no calibration information found")) |> out(out_format)
    end
    const calibration_data = CalibrationData(req_dict[CALIBRATION_INFO_KEY])
    #
    ## parse melting curve data into DataFrame
    # const mc_data = MeltCurveRawData(req_dict[RAW_DATA_KEY])
    const mc_parsed_raw_data = mc_parse_raw_data(req_dict[RAW_DATA_KEY])
    #
    ## parse analysis parameters from request
    const kwargs_pa = OrderedDict{Symbol,Any}(
        map(keys(MC_PEAK_ANALYSIS_KEYWORDS)) do key
            key => req_dict[MC_PEAK_ANALYSIS_KEYWORDS[key]]
        end) ## do key
    #
    ## create container for data and parameter values
    interface = McInput(
            calibration_data,
            mc_parsed_raw_data...;
            dcv = DEFAULT_MC_DCV && mc_parsed_raw_data[3] > 1, ## num_channels > 1
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


#=============================================================================================#


## extract dimensions of raw melting curve data
## and format as a DataFrame
function mc_parse_raw_data(raw_dict ::Associative)
    const mc_raw_df = DataFrame()
    foreach(keys(MC_RAW_FIELDS)) do key
        try
            mc_raw_df[key] = raw_dict[MC_RAW_FIELDS[key]]
        catch()
            throw(DimensionMismatch("the format of the raw data is incorrect:" *
                "each data field should have the same length"))
        end ## try
    end ## next key
    const (fluo_well_nums, channel_nums) =
        map([WELL_NUM_KEY, CHANNEL_KEY]) do key
            raw_dict[key] |> unique |> sort
        end
    const (num_fluo_wells, num_channels) =
        map(length, (fluo_well_nums, channel_nums))
    return (
        mc_raw_df,
        num_fluo_wells,
        num_channels,
        fluo_well_nums,
        channel_nums)
end ## mc_parse_raw_data()


#=============================================================================================#


## analyse melting curve experiment
function mc_analysis(i ::McInput)

    ## function: format fluorescence data for calibration
    ##
    ## >> PROBLEM >>
    ## this function generates a lot of intermediate representations
    ## and might be sped up by creating an appropriate container
    ## and mutating it in place
    function get_mc_data(channel_num ::Integer)

        ## subset melting curve data by channel (curried)
        select_mcdata_by_channel(channel_num ::Integer) =
            mc_data ::DataFrame ->
                Dict(
                    map([:temperature, :fluorescence, :well]) do f
                        f => mc_data[f][mc_data[:channel] .== channel_num]
                    end)

        ## split temperature and fluorescence data by well
        ## return vector of TF Dicts
        split_tf_by_well(fluo_sel ::Associative) =
            map(i.fluo_well_nums) do well
                Dict(
                    map(MC_TF_KEYS) do key
                        key => fluo_sel[key][fluo_sel[:well] .== well]
                    end)
            end

        ## extend data vectors with NaN values where necessary to make them equal in length
        ## this is performed to convert the fluorescence data to a 3D array
        ##
        ## >> PROBLEM >>
        ## although it is unlikely that the maximum vector length varies by channel
        ## if it does the arrays (which are generated separately by channel)
        ## will not be conformable and the data transformation will throw an error
        extend_tf_vecs(tf_dict_vec ::AbstractArray) =
            map(tf_dict_vec) do tf_dict
                Dict(
                    map(MC_TF_KEYS) do key
                        key => extend_NaN(
                                    maximum(
                                        map(length ∘ index(:temperature),
                                            tf_dict_vec)))(tf_dict[key])
                    end)
            end

        ## convert to MeltCurveTF object
        toMeltCurveTF(tf_nv_adj ::AbstractArray) =
            MeltCurveTF(
                map(MC_TF_KEYS) do key
                    mapreduce(index(key), hcat, tf_nv_adj)
                end...)

    ## << end of function definitions nested in get_mc_data()

    ## calculate
        i.raw_df |>
        select_mcdata_by_channel(channel_num) |>
        split_tf_by_well |>
        extend_tf_vecs |>
        toMeltCurveTF
    end ## get_mc_data

    normalize_tf(ci ::Integer, wi ::Integer) =
        normalize_fluos(
            remove_when_temperature_NaN(
                mc_data_bychannel[ci].temperature[:, wi],
                calibrated_data[:, wi, ci])...)

    remove_when_temperature_NaN(x...) =
        # map(y -> y[broadcast(!isnan, first(x))], x)
        map(first(x) |> cast(!isnan) |> index, x)

    ## subtract lowest fluorescence value
    ## NB if any value is NaN, the result will be all NaNs
    normalize_fluos(
        temperatures    ::DataArray{<: AbstractFloat},
        fluos_raw       ::AbstractVector{<: AbstractFloat}) =
            Dict(
                :temperatures   => temperatures,
                :fluos          => sweep(minimum)(-)(fluos_raw))

    ## << end of function definitions nested in mc_analysis()

    debug(logger, "at mc_analysis()")
    # const (channel_nums, fluo_well_nums) =
    #     map((:channel, :well)) do fieldname
    #         i.raw_df[fieldname] |> unique |> sort
    #     end ## do fieldname
    # const num_channels      = length(channel_nums)
    # const num_fluo_wells    = length(fluo_well_nums)
    #
    ## get data arrays by channel
    ## output is Vector{MeltCurveTF}
    const mc_data_bychannel = map(get_mc_data, i.channel_nums)
    #
    ## reshape raw fluorescence data to 3-dimensional array
    ## dimensions 1,2,3 = temperature,well,channel
    const mc_data_array     = cat(3, map(field(:fluorescence), mc_data_bychannel)...)
    const raw_data          = RawFluo(mc_data_array)
    #
    ## deconvolute and normalize
    const peak_format = peak_output_format(i.out_format)
    if peak_format == Type{McPeakLongOutput}
        o = McLongOutput()
        o.channel_nums = i.channel_nums
        o.fluo_well_nums = i.fluo_well_nums
        o.raw_data = raw_data
        (   o.background_subtracted_data,
            o.k4dcv,
            o.deconvoluted_data,
            o.norm_data,
            _,                                  ## discard norm_well_nums
            calibrated_data                 ) =
            calibrate(
                raw_data,
                i.calibration_data,
                i.fluo_well_nums,
                i.channel_nums;
                dcv = i.dcv,
                data_format = array)
        o.calibrated_data = calibrated_data
        ## ignore dummy well_nums from calibrate()
        o.norm_well_nums = i.fluo_well_nums
    else
        ## McPeakShortOutput
        const (_, _, _, _, _, calibrated_data) = ## discard other output fields
            calibrate(
                raw_data,
                i.calibration_data,
                i.fluo_well_nums,
                i.channel_nums;
                dcv = i.dcv,
                data_format = array)
    end ## if peak_format
    #
    ## ignore dummy well_nums from calibrate()
    const norm_well_nums = i.fluo_well_nums
    #
    ## subset temperature/fluorescence data by channel then by well
    ## then smooth the fluorescence/temperature data and calculate Tm peak, area
    ## bychwl = by channel then by well_nums
    const mc_bychannelwell =
        mapreduce(
            ci ->
                map(eachindex(i.fluo_well_nums)) do wi
                    if i.fluo_well_nums[wi] in norm_well_nums
                        mc_peak_analysis(
                            i,
                            peak_format,
                            normalize_tf(ci, wi))
                    else
                        McPeakOutput(peak_format)
                    end
                end, ## do w
            hcat,
            1:i.num_channels)
    #
    # if (i.out_format == full_output)
    if peak_format == Type{McPeakLongOutput}
        o.peak_output = mc_bychannelwell
        return o
    else
        ## json_output, pre_json_output
        ## McPeakShortOutput
        output_dict = OrderedDict{Symbol,Any}(map(keys(MC_OUTPUT_FIELDS)) do f
            MC_OUTPUT_FIELDS[f] =>
                [   i.reporting(getfield(mc_bychannelwell[wi, ci], f))
                    for wi in 1:i.num_fluo_wells, ci in 1:i.num_channels ]
        end) ## do f
        output_dict[:valid] = true
        return output_dict
    end ## if out_format
end ## mc_analysis()
