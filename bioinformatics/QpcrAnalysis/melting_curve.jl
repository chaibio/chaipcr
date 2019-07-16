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
    const (well_nums, channel_nums) =
        map([WELL_NUM_KEY, CHANNEL_KEY]) do key
            raw_dict[key] |> unique |> sort
        end
    const (num_wells, num_channels) =
        map(length, (well_nums, channel_nums))
    return (
        mc_raw_df,
        num_wells,
        num_channels,
        well_nums,
        channel_nums)
end ## mc_parse_raw_data()


#=============================================================================================#


## analyse melting curve experiment
function mc_analysis(i ::McInput)

    # ## function: format fluorescence data for calibration
    # ##
    # ## >> PROBLEM >>
    # ## this function generates a lot of intermediate representations
    # ## and might be sped up by creating an appropriate container
    # ## and mutating it in place
    # function get_mc_data(channel_num ::Integer)
    #        
    #     ## subset melting curve data by channel (curried)
    #     select_mcdata_by_channel(channel_num ::Integer) =
    #         mc_data ::DataFrame ->
    #             Dict(
    #                 map([:temperature, :fluorescence, :well]) do f
    #                     f => mc_data[f][mc_data[:channel] .== channel_num]
    #                 end)
    #        
    #     ## split temperature and fluorescence data by well
    #     ## return vector of TF Dicts
    #     split_tf_by_well(fluo_sel ::Associative) =
    #         map(i.well_nums) do well
    #             Dict(
    #                 map(MC_TF_KEYS) do key
    #                     key => fluo_sel[key][fluo_sel[:well] .== well]
    #                 end)
    #         end
    #
    #     ## extend array elements with NaNs to length of longest element
    #     @inline extend(x ::AbstractArray) =
    #         map(extend_NaN(y |> mold(length) |> maximum), x)
    #
    #     ## extend data vectors with NaN values where necessary to make them equal in length
    #     ## this is performed to convert the fluorescence data to a 3D array
    #     ##
    #     ## >> PROBLEM >>
    #     ## although it is unlikely that the maximum vector length varies by channel
    #     ## if it does the arrays (which are generated separately by channel)
    #     ## will not be conformable and the data transformation will throw an error
    #     extend_tf_vecs(tf_dict_vec ::AbstractArray) =
    #         map(tf_dict_vec) do tf_dict
    #             Dict(
    #                 map(MC_TF_KEYS) do key
    #                     key => extend_NaN(
    #                                 maximum(
    #                                     map(length ∘ index(:temperature),
    #                                         tf_dict_vec)))(tf_dict[key])
    #                 end)
    #         end
    #        
    #     ## convert to MeltCurveTF object
    #     toMeltCurveTF(tf_nv_adj ::AbstractArray) =
    #         MeltCurveTF(
    #             map(MC_TF_KEYS) do key
    #                 mapreduce(index(key), hcat, tf_nv_adj)
    #             end...)
    #        
    # ## << end of function definitions nested in get_mc_data()
    #        
    # ## calculate
    #     return i.raw_df |>
    #             select_mcdata_by_channel(channel_num) |>
    #             split_tf_by_well |>
    #             extend_tf_vecs |>
    #             toMeltCurveTF
    # end ## get_mc_data

    ## convert DataFrame to 3D array of fluorescences suitable for calibration
    function transform_3d(df)
        ## split-apply-combine style
        # extended = copy(df)
        # extended[:fluorescence] = Vector{Float_T}(extended[:fluorescence]) ## to allow NaN
        # const lengths = by(extended, [:channel, :well],
        #     df -> DataFrame(len=length(df[:temperature])))
        # const longest = maximum(lengths[:len])
        # for j in 1:size(lengths, 1),
        #     k in range(1, longest - lengths[:len][j])
        #     push!(extended, Dict(
        #         :temperature    => NaN,
        #         :fluorescence   => NaN,
        #         :channel        => lengths[:channel][j],
        #         :well           => lengths[:well][k]))
        # end ## next j, k
        # const f =
        #     reshape(
        #         hcat(by(extended, [:channel, :well], df -> df[:fluorescence])[:x1]...)',
        #         i.num_channels, i.num_wells, longest) |>
        #     RawData{Float_T}
        #
        ## devectorized style
        cs = [df[:channel] .== c for c in i.channel_nums]
        ws = [df[:well   ] .== w for w in i.well_nums   ]
        const selection =
            [   find(cs[ci] .& ws[wi]) 
                for ci in eachindex(i.channel_nums), wi in eachindex(i.well_nums)   ]
        # @inline selector(c ::Int, w ::Int) = (df[:channel] .== c) .& (df[:well] .== w)
        # const selection =
        #     [   find(selector(c, w))
        #         for c in i.channel_nums, w in i.well_nums   ]
        const longest = selection |> mold(length) |> maximum
        const dims = (longest, i.num_wells, i.num_channels)
        t = Array{Float_T}(dims)
        f = Array{Float_T}(dims)
        for ci in eachindex(i.channel_nums)
            # c = i.channel_nums[ci]
            for wi in eachindex(i.well_nums)
                # w = i.well_nums[wi]
                location = selection[ci, wi]
                let ## to future-proof access to ti outside the for-loop: scoping rules change after v0.6
                    ti = 0
                    for ti in eachindex(location)
                        t[ti, wi, ci] = df[location[ti], :temperature ]
                        f[ti, wi, ci] = df[location[ti], :fluorescence]
                    end ## next ti
                    for ti in (ti + 1):longest
                        t[ti, wi, ci] = NaN
                        f[ti, wi, ci] = NaN
                    end ## next ti
                end ## let
            end ## next wi
        end ## next ci
        return RawData(t), RawData(f)
    end ## transform_3d()
           
    normalize_tf(ci ::Integer, wi ::Integer) =
        normalize_fluos(
            remove_when_temperature_NaN(
                # mc_data_bychannel[ci].temperature[:, wi],
                raw_temps.data[ :, wi, ci],
                calibrated_data[:, wi, ci])...)
           
    remove_when_temperature_NaN(x...) =
        # map(y -> y[broadcast(!isnan, first(x))], x)
        x |> mold(first(x) |> cast(!isnan) |> index)
           
    ## subtract lowest fluorescence value
    ## NB if any value is NaN, the result will be all NaNs
    normalize_fluos(
        temperatures    ::AbstractVector{<: AbstractFloat},
        fluos_raw       ::AbstractVector{<: AbstractFloat}) =
            Dict(
                :temperatures   => temperatures,
                :fluos          => sweep(minimum)(-)(fluos_raw))
            
    # ## << end of function definitions nested in mc_analysis()

    debug(logger, "at mc_analysis()")
    # const (channel_nums, well_nums) =
    #     map((:channel, :well)) do fieldname
    #         i.raw_df[fieldname] |> unique |> sort
    #     end ## do fieldname
    # const num_channels      = length(channel_nums)
    # const num_wells         = length(well_nums)
    #
    ## get data arrays by channel
    ## output is Vector{MeltCurveTF}
    # const mc_data_bychannel = map(get_mc_data, i.channel_nums)
    #
    ## reshape raw fluorescence data to 3-dimensional array
    ## dimensions 1,2,3 = temperature,well,channel
    # const mc_data_array     = cat(3, map(field(:fluorescence), mc_data_bychannel)...)
    # const raw_fluos         = RawData(mc_data_array)
    
    ## alternative method, manipulating DataFrame directly
    const (raw_temps, raw_fluos) = transform_3d(i.raw_df)
    #
    ## deconvolute and normalize
    const peak_format = peak_output_format(i.out_format)
    if peak_format == McPeakLongOutput
        (   background_subtracted_data,
            k4dcv,
            deconvoluted_data,
            norm_data,
            _,                                  ## discard norm_well_nums
            calibrated_data                 ) =
            calibrate(
                raw_fluos,
                i.calibration_data,
                i.well_nums,
                i.channel_nums;
                dcv = i.dcv,
                data_format = array)
        ## ignore dummy well_nums from calibrate()
    else
        ## McPeakShortOutput
        const (_, _, _, _, _, calibrated_data) = ## discard other output fields
            calibrate(
                raw_fluos,
                i.calibration_data,
                i.well_nums,
                i.channel_nums;
                dcv = i.dcv,
                data_format = array)
    end ## if peak_format
    #
    ## ignore dummy well_nums from calibrate()
    const norm_well_nums = i.well_nums
    #
    ## subset temperature/fluorescence data by channel / well
    ## then smooth the fluorescence/temperature data and calculate Tm peak, area
    ## result is mc_matrix: dim1 = well, dim2 = channel
    const mc_matrix =
        eachindex(i.channel_nums) |> ## do for each channel
        moose(
            ci ->
                map(eachindex(i.well_nums)) do wi
                    if i.well_nums[wi] in norm_well_nums
                        mc_peak_analysis(
                            i,
                            peak_format,
                            normalize_tf(ci, wi))
                    else
                        McPeakOutput(peak_format)
                    end
                end, ## do wi
            hcat) |>
        morph(i.num_wells, i.num_channels) ## coerce to 2d array
    #
    # if (i.out_format == full_output)
    if peak_format == McPeakLongOutput
        return McLongOutput(
            i.channel_nums,
            i.well_nums,
            raw_fluos.data,
            background_subtracted_data,
            k4dcv,
            deconvoluted_data,
            norm_data,
            i.well_nums,
            calibrated_data,
            mc_matrix)
    else
        ## json_output, pre_json_output
        ## McPeakShortOutput
        output_dict = OrderedDict{Symbol,Any}(map(keys(MC_OUTPUT_FIELDS)) do f
            MC_OUTPUT_FIELDS[f] =>
                [   i.reporting(getfield(mc_matrix[wi, ci], f))
                    for wi in 1:i.num_wells, ci in 1:i.num_channels ]
        end) ## do f
        output_dict[:valid] = true
        return output_dict
    end ## if out_format
end ## mc_analysis()
