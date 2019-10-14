#===============================================================================

    mc_analysis.jl

    perform melting curve analysis

    Author: Tom Price
    Date:   July 2019

===============================================================================#

import DataStructures.OrderedDict
import DataFrames.DataFrame
import Memento: debug



#===============================================================================
    field names >>
===============================================================================#

# const MC_TF_KEYS = [:temperature, :fluorescence]
const MC_OUTPUT_FIELDS = OrderedDict(
    :observed_data          => :melt_curve_data,
    :peaks_filtered         => :melt_curve_analysis)


#===============================================================================
    function definitions >>
===============================================================================#

"Analyse a melting curve experiment via calls to `calibrate` and `mc_peak_analysis`."
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
    #         map(i.wells) do well
    #             Dict(
    #                 map(MC_TF_KEYS) do key
    #                     key => fluo_sel[key][fluo_sel[:well] .== well]
    #                 end)
    #         end
    #
    # "Curried function that extends a vector with NaN values to a specified length."
    # extend_NaN(len ::Integer) =
    #     vec ::AbstractVector ->
    #         len - length(vec) |>
    #             m ->
    #                 m >= 0 ?
    #                     vcat(vec, fill(NaN_T, m)) :
    #                     error(logger, "vector is too long")
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

    "Convert raw melting curve data from a DataFrame to 3D array of fluorescences
    as required by `calibrate`."
    function transform_3d(df ::DataFrame)
        ## split-apply-combine style
        # extended = copy(df)
        # extended[:fluorescence] = Vector{Float_T}(extended[:fluorescence]) ## to allow NaN
        # const lengths = by(extended, [:channel, :well],
        #     df -> DataFrame(len=length(df[:temperature])))
        # const longest = maximum(lengths[:len])
        # for j in 1:size(lengths, 1),
        #     k in range(1, longest - lengths[:len][j])
        #     push!(extended, Dict(
        #         :temperature    => NaN_T,
        #         :fluorescence   => NaN_T,
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
        cs = [df[:channel] .== c for c in i.channels]
        ws = [df[:well   ] .== w for w in i.wells   ]
        const selection =
            [   find(cs[ci] .& ws[wi])
                for ci in eachindex(i.channels), wi in eachindex(i.wells)   ]
        # @inline selector(c ::Int, w ::Int) = (df[:channel] .== c) .& (df[:well] .== w)
        # const selection =
        #     [   find(selector(c, w))
        #         for c in i.channels, w in i.wells   ]
        const longest = selection |> mold(length) |> maximum
        const dims = (longest, i.num_wells, i.num_channels)
        t = Array{Float_T}(dims)
        f = Array{Float_T}(dims)
        for ci in eachindex(i.channels)
            # c = i.channels[ci]
            for wi in eachindex(i.wells)
                # w = i.wells[wi]
                location = selection[ci, wi]
                let ## to future-proof access to `ti` outside the for-loop:
                    ## scoping rules change after v0.6
                    ti = 0
                    for ti in eachindex(location)
                        t[ti, wi, ci] = df[location[ti], :temperature ]
                        f[ti, wi, ci] = df[location[ti], :fluorescence]
                    end ## next ti
                    for ti in (ti + 1):longest
                        t[ti, wi, ci] = NaN_T
                        f[ti, wi, ci] = NaN_T
                    end ## next ti
                end ## let
            end ## next wi
        end ## next ci
        return RawData(t), RawData(f)
    end ## transform_3d()

    normalize_tf(ci ::Integer, wi ::Integer) =
        normalize_fluos!(
            remove_when_temperature_NaN(
                DataFrame(
                    :temperature    => raw_temps.data[ :, wi, ci],
                    :fluorescence   => calibrated_data[:, wi, ci])))

    "Take as input a vector of temperatures and a vector of fluorescences, and set
    the fluorescence to NaN wherever the corresponding temperature value is NaN."
    remove_when_temperature_NaN(df ::DataFrame) =
        df[.!isnan.(df[:temperature]), :]

    "Normalize fluorescences values by subtracting the lowest value. Note that
    if any value is NaN, the result will be a vector of NaNs."
    function normalize_fluos!(df ::DataFrame)
        df[:fluorescence] = sweep(minimum)(-)(df[:fluorescence])
        return df
    end

    ## << end of function definitions nested in mc_analysis()

    debug(logger, "at mc_analysis()")
    # const (channels, wells) =
    #     map((:channel, :well)) do fieldname
    #         i.raw_df[fieldname] |> unique |> sort
    #     end ## do fieldname
    # const num_channels      = length(channels)
    # const num_wells         = length(wells)
    #
    ## get data arrays by channel
    ## output is Vector{MeltCurveTF}
    # const mc_data_bychannel = map(get_mc_data, i.channels)
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
            k_deconv,
            deconvoluted_data,
            norm_data,
            norm_wells,
            calibrated_data ) =
                calibrate(i, i.calibration_data, i.calibration_args, raw_fluos, array)
    else
        ## McPeakShortOutput
        const (_, _, _, _, norm_wells, calibrated_data) = ## discard other output fields
            calibrate(i, i.calibration_data, i.calibration_args, raw_fluos, array)
    end ## if peak_format
    #
    ## subset temperature/fluorescence data by channel / well
    ## then smooth the fluorescence/temperature data and calculate Tm peak, area
    ## result is mc_matrix: dim1 = well, dim2 = channel
    const mcpa_matrix =
        eachindex(i.channels) |> ## do for each channel
        moose(hcat) do ci
            map(eachindex(i.wells)) do wi
                if i.wells[wi] in norm_wells
                    mc_peak_analysis(peak_format, i, normalize_tf(ci, wi))
                else
                    McPeakOutput(peak_format)
                end ## if
            end ## next wi
        end #= next ci =# |>
        morph(length(norm_wells), i.num_channels) ## coerce to 2d array
    #
    # if (i.out_format == full_output)
    if peak_format == McPeakLongOutput
        return McLongOutput(
            i.wells,
            i.channels,
            raw_fluos.data,
            background_subtracted_data,
            k_deconv,
            deconvoluted_data,
            norm_data,
            i.wells,
            calibrated_data,
            mcpa_matrix)
    else
        ## json_output, pre_json_output
        ## McPeakShortOutput
        output_dict = OrderedDict{Symbol,Any}(
            map(keys(MC_OUTPUT_FIELDS)) do f
                MC_OUTPUT_FIELDS[f] =>
                    [   i.reporting(getfield(mcpa_matrix[wi, ci], f))
                        for wi in 1:i.num_wells, ci in 1:i.num_channels ]
            end) ## do f
        output_dict[:valid] = true
        return output_dict
    end ## if out_format
end ## mc_analysis()
