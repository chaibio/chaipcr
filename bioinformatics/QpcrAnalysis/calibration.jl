#==============================================================================================

    calibration.jl

    calibration procedure:
    1. multichannel deconvolution
    2. normalize variation between wells in absolute fluorescence
    
==============================================================================================#

import DataStructures.OrderedDict
import StaticArrays: SArray
import Memento: debug, error



#==============================================================================================
    constants >>
==============================================================================================#

## Enum type for K matrix calculation
## used in deconvolution.jl
@enum WellProc well_proc_mean well_proc_vec

## default values
const DEFAULT_CAL_DYE_IN            = :FAM
const DEFAULT_CAL_DYES_TO_FILL      = []
const DEFAULT_NORM_MINUS_WATER      = false
const DEFAULT_DCV_BACKUP_K          = K4DCV
const DEFAULT_DCV_WELL_PROC         = well_proc_vec

## preset values
const NORMALIZATION_SCALING_FACTOR  = 3.7           ## used: 9e5, 1e5, 1.2e6, 3.0
const DECONVOLUTION_SCALING_FACTOR  = [1.0, 4.2]    ## used: [1, oneof(1, 2, 3.5, 8, 7, 5.6, 4.2)]



#==============================================================================================
    function definitions >>
==============================================================================================#

## function: perform deconvolution between channels and normalize variation between wells
function calibrate(
    ## data
    raw                     ::RawData{<: Real},         ## 3D array of raw fluorescence by cycle/temp, well, channel
    calibration_data        ::CalibrationData{<: Real}, ## calibration dataset
    well_nums_found_in_raw  ::AbstractVector,           ## vector of well numbers
    channel_nums            ::AbstractVector;           ## vector of channel numbers
    ## calibration parameters
    dcv                     ::Bool = true,              ## if true, perform multi-channel deconvolution
    dye_in                  ::Symbol = DEFAULT_CAL_DYE_IN,
    dyes_to_fill            ::AbstractVector = DEFAULT_CAL_DYES_TO_FILL,
    ## output parameter
    data_format             ::DataFormat = array        ## array, dict, both
)
    debug(logger, "at calibrate()")

    ## remove MySql dependency
    # calib_info = ensure_ci(db_conn, calib_info)
    # norm_data, norm_well_nums = prep_normalize(db_conn, calib_info, well_nums_in_req, dye_in, dyes_to_fill)

    ## assume without checking that we are using all the wells, all the time
    const well_nums_in_req = calibration_data |> num_wells |> from(0) |> collect
    #
    ## prepare data for normalization
    const (norm_data, norm_well_nums) =
        prep_normalize(calibration_data, well_nums_in_req, dye_in, dyes_to_fill)
    #
    ## overwrite the dummy well_nums
    norm_well_nums = well_nums_found_in_raw
    #
    const num_channels = length(channel_nums)
    # if length(well_nums_found_in_raw) == 0
    #     well_nums_found_in_raw = norm_well_nums
    # end

    ## remove MySql dependency
    #
    # matched_well_idc = find(norm_well_nums) do norm_well_num
    #     norm_well_num in well_nums_found_in_raw
    # end ## do norm_well_num

    ## issue:
    ## we can't match well numbers between calibration data and experimental data
    ## because we don't have that information for the calibration data
    const matched_well_idc = norm_well_nums |> length |> from(1) |> collect
    #
    ## subtract background
    const background_subtracted_data =
        cat(3,
            ## devectorized code avoids transposition
            [
                [   raw.data[ui, wi, ci] - norm_data[:water][ci][matched_well_idc][wi]
                    for ui in 1:size(raw.data, 1),
                        wi in matched_well_idc    ]
                for ci in 1:num_channels                ]...)
    #
    const (k4dcv, deconvoluted_data) =
        if dcv
            ## addition with flexible ratio instead of deconvolution (commented out)
            # k_inv_vec = fill(reshape(DataArray([1, 0, 1, 0]), 2, 2), 16)

            ## removing MySql dependency
            # k4dcv, deconvoluted_data = deconvolute(
            #     1. * background_subtracted_data, channel_nums, matched_well_idc, db_conn, calib_info, well_nums_in_req;
            #     out_format="array")
            deconvolute(
                1. * background_subtracted_data,
                channel_nums,
                matched_well_idc,
                calibration_data,
                well_nums_in_req,
                DEFAULT_DCV_BACKUP_K,
                DEFAULT_DCV_WELL_PROC,
                DECONVOLUTION_SCALING_FACTOR,
                array)
        else ## !dcv
            K4Deconv(), background_subtracted_data
        end
    #
    const calibrated_dict =
        OrderedDict(
            map(range(1, num_channels)) do channel_i
                channel_nums[channel_i] =>
                    normalize(
                        deconvoluted_data[:, :, channel_i],
                        norm_data,
                        matched_well_idc,
                        channel_i,
                        DEFAULT_NORM_MINUS_WATER,
                        NORMALIZATION_SCALING_FACTOR)
            end) ## do channel_i
    #
    ## format output
    ## the following line of code needs the keys of calibrated_dict to be in sort order
    calibrated_array() = cat(3, values(calibrated_dict)...)
    const calibrated_data =
        if      (data_format == array)  tuple(calibrated_array())
        elseif  (data_format == dict)   tuple(calibrated_dict)
        elseif  (data_format == both)   tuple(calibrated_array(), calibrated_dict)
        else                            throw(ArgumentException(
                                            "`data_format` must be array, dict or both"))
        end ## if
    return (background_subtracted_data, k4dcv, deconvoluted_data,
            norm_data, norm_well_nums, calibrated_data...)
end ## calibrate()


#=============================================================================================#


## function: check whether the data in optical calibration experiment is valid
function prep_normalize(
    calibration_data    ::CalibrationData{C},
    well_nums           ::AbstractVector,
    dye_in              ::Symbol,
    dyes_to_fill        ::AbstractVector,
) where {C <: Real}
    debug(logger, "at prep_normalize()")
    ## issue:
    ## using the current format for the request body there is no well_num information
    ## associated with the calibration data
    signal_data_dict = OrderedDict{Int,Vector{C}}() ## | use type of calibration data
    water_data_dict  = OrderedDict{Int,Vector{C}}() ## |
    stop_msgs  = Vector{String}()
    for channel in 1:calibration_data.num_channels
        key = Symbol(CHANNEL_KEY, "_", string(channel))
        try
            water_data_dict[channel]  = calibration_data.water[channel]
        catch()
            push!(stop_msgs, "Cannot access water calibration data for channel $channel")
        end ## try
        try
            signal_data_dict[channel] = getfield(calibration_data, key)[channel]
        catch()
            push!(stop_msgs, "Cannot access signal calibration data for channel $channel")
        end ## try
        if length(water_data_dict[channel]) != length(signal_data_dict[channel])
            push!(stop_msgs, "Calibration data lengths are not equal for channel $channel")
        end
    end ## next channel
    (length(stop_msgs) > 0) && throw(DomainError(join(stop_msgs, "; ")))
    #
    const (channels_in_water, channels_in_signal) =
        map(get_ordered_keys, (water_data_dict, signal_data_dict))
    ## assume without checking that there are no missing wells anywhere
    const signal_well_nums = collect(eachindex(signal_data_dict[1]))
    ## check whether signal fluorescence > water fluorescence
    for channel in channels_in_signal
        const norm_invalid_idc = find(signal_data_dict[channel] .<= water_data_dict[channel])
        if length(norm_invalid_idc) > 0
            const failed_well_nums_str = join(signal_well_nums[norm_invalid_idc], ", ")
            push!(stop_msgs, "invalid well-to-well variation data in channel $channel: " *
                "fluorescence value of water is greater than or equal to that of dye " *
                "in the following well(s) - $failed_well_nums_str")
        end ## if invalid
    end ## next channel
    (length(stop_msgs) > 0) && throw(DomainError(join(stop_msgs, "; ")))
    #
    ## issue:
    ## this feature has been temporarily disabled while
    ## removing MySql dependency in get_wva_data because
    ## using the current format for the request body
    ## we cannot subset the calibration data by step_id
    # if length(dyes_to_fill) > 0 ## extrapolate well-to-well variation data for missing channels
    #     println("Preset well-to-well variation data is used to extrapolate calibration data for missing channels.")
    #     channels_missing = setdiff(channels_in_water, channels_in_signal)
    #     dyes_dyes_to_fill_channels = map(dye -> DYE2CHST[dye]["channel"], dyes_to_fill) ## DYE2CHST is defined in module scope
    #     check_subset(
    #         Ccsc(channels_missing, "Channels missing well-to-well variation data"),
    #         Ccsc(dyes_dyes_to_fill_channels, "channels corresponding to the dyes of which well-to-well variation data is needed")
    #     )
    #     # process preset calibration data
    #     preset_step_ids = OrderedDict([
    #         dye => DYE2CHST[dye]["step_id"]
    #         for dye in keys(DYE2CHST)
    #     ])
    #     preset_signal_data_dict, dyes_in_preset = get_wva_data(PRESET_calib_ids["signal"], preset_step_ids, db_conn, "dye") ## `well_nums` is not passed on
    #     pivot_preset = preset_signal_data_dict[dye_in]
    #     pivot_in = signal_data_dict[DYE2CHST[dye_in]["channel"]]
    #     in2preset = pivot_in ./ pivot_preset
    #     for dye in dyes_to_fill
    #         signal_data_dict[DYE2CHST[dye]["channel"]] = preset_signal_data_dict[dye] .* in2preset
    #     end
    # end ## if

    ## water_data and signal_data are OrderedDict objects keyed by channels,
    ## to accommodate the situation where calibration data has more channels
    ## than experiment data, so that the calibration data needs to be easily
    ## subsetted by channel.
    const norm_data = OrderedDict(
        :water  => water_data_dict,
        :signal => signal_data_dict)
    return (norm_data, signal_well_nums)
end ## prep_normalize


#=============================================================================================#


## function: normalize variation between wells in absolute fluorescence values (normalize).
## each dye only has data for its target channel;
## calibration/calib/oc - used for `deconvolute` and `normalize`,
## each dye has data for both target and non-target channels.
## Input `fluo` and output: dim2 indexed by well and dim1 indexed by unit,
## which can be cycle (amplification) or temperature point (melt curve).
## Output does not include the automatically created column at index 1
## from rownames of input array as R does
function normalize(
    fluorescence                    ::Array{<: Real,2},
    norm_data                       ::Associative,
    matched_well_idc                ::AbstractVector,
    channel                         ::Integer,
    minus_water                     ::Bool,
    normalization_scaling_factor    ::Real,
)
    debug(logger, "at normalize()")
    #
    ## devectorized code avoids transposing data matrix
    if minus_water == false
        const swd = norm_data[:signal][channel][matched_well_idc]
        return ([
            normalization_scaling_factor * mean(swd) *
                fluorescence[i,w] / swd[w]
                    for i in 1:size(fluorescence, 1),
                        w in 1:size(fluorescence, 2)]) ## w = well
    end
    #
    ## minus_water == true
    const norm_water = norm_data[:water][channel][matched_well_idc]
    const swd = norm_data[:signal][channel][matched_well_idc] .- norm_water
    return ([
        normalization_scaling_factor * mean(swd) *
            (fluorescence[i,w] - norm_water[w]) / swd[w]
                for i in 1:size(fluorescence, 1),
                    w in 1:size(fluorescence, 2)]) ## w = well
end ## normalize


#=============================================================================================#


## multi-channel deconvolution
function deconvolute(
    ## ary2dcv dim1 is unit, which can be cycle (amplification), temperature point (melting curve),
    ## or step type (like "water", "channel_1", "channel_2" for calibration experiment);
    ## ary2dcv dim2 must be well, ary2dcv dim3 must be channel
    ary2dcv                 ::AbstractArray,
    channel_nums            ::AbstractVector,
    dcv_well_idc_wfluo      ::AbstractVector,
    calibration_data        ::CalibrationData{<: Real},
    well_nums               ::AbstractVector,
    k4dcv_backup            ::K4Deconv, ## argument not used
    k4dcv_well_proc         ::WellProc,
    scaling_factor_dcv_vec  ::AbstractVector,
    data_format             ::DataFormat, ## array, dict, both
    
    ## remove MySql dependency
    #
    ## arguments needed if `k` matrix needs to be computed
    ## `db_conn_default` is defined in "__init__.jl"
    # db_conn ::MySQL.MySQLHandle=db_conn_default,
    # calib_info ::Union{Integer,OrderedDict}=calib_info_AIR,
    # well_nums ::AbstractVector=[];
)
    debug(logger, "at deconvolute()")

    ## remove MySql dependency
    # k4dcv = (isa(calib_info, Integer) || begin
    #     step_ids = map(ci_value -> ci_value["step_id"], values(calib_info))
    #     length_step_ids = length(step_ids)
    #     length_step_ids <= 2 || length(unique(step_ids)) < length_step_ids
    # end) ? k4dcv_backup : get_k(db_conn, calib_info, well_nums) ## use default `well_proc` value
    const k4dcv = get_k(calibration_data, well_nums, k4dcv_well_proc)
    const (a2d_dim_unit, a2d_dim_well, a2d_dim_channel) = size(ary2dcv)
    const k_inv_vs =
        map(range(1, a2d_dim_well)) do w
            k4dcv.k_inv_vec[dcv_well_idc_wfluo[w]] .* scaling_factor_dcv_vec
        end
    deconvoluted_array = similar(ary2dcv)
    for x in range(1, a2d_dim_unit), w in range(1, a2d_dim_well)
        deconvoluted_array[x, w, :] = k_inv_vs[w] * ary2dcv[x, w, :] ## matrix * vector
    end
    deconvoluted_dict() =
        OrderedDict(map(range(1, a2d_dim_channel)) do channel_i
            channel_nums[channel_i] => deconvoluted_array[:, :, channel_i]
        end) ## do channel_i
    ## format output
    const deconvoluted_data =
        if      (data_format == array)  tuple(deconvoluted_array)
        elseif  (data_format == dict)   tuple(deconvoluted_dict())
        elseif  (data_format == both)   tuple(deconvoluted_array, deconvoluted_dict())
        else
            throw(ArgumentError("`out_format` must be array, dict or both"))
        end ## if
    return (k4dcv, deconvoluted_data...)
end ## deconvolute()


#=============================================================================================#


## function: get cross-over constant matrix `k`
function get_k(
    ## remove MySql dependency
    # db_conn ::MySQL.MySQLHandle,

    ## info on experiment(s) used to calculate matrix K
    ## OrderedDict(
    ##    "water"    =OrderedDict(calibration_id=..., step_id=...),
    ##    "channel_1"=OrderedDict(calibration_id=..., step_id=...),
    ##    "channel_2"=OrderedDict(calibration_id=..., step_id=...))
    # dcv_exp_info ::OrderedDict,

    ## possible  issue:
    ## step_ids are not provided together with calibration data
    ## I'm not sure that this is a problem because the calibration data
    ## in the request body is already specific to a single step.
    calibration_data    ::CalibrationData{<: Real},
    well_nums           ::AbstractVector,
    well_proc           ::WellProc; ## options: well_proc_mean, well_proc_vec
    save_to             ::String ="" ## used: "k.jld"
)
    debug(logger, "at get_k()")

    ## remove MySql dependency
    #
    # dcv_exp_info = ensure_ci(db_conn, dcv_exp_info)
    #
    # calib_key_vec = get_ordered_keys(dcv_exp_info)
    # cd_key_vec = calib_key_vec[2:end] # cd = channel of dye. "water" is index 1 per original order.
    #
    # dcv_data_dict = get_full_calib_data(db_conn, dcv_exp_info, well_nums)
    #
    # water_data, water_well_nums = dcv_data_dict["water"]
    # num_wells = length(water_well_nums)
    #
    ## `dcv_well_nums` is not passed on because expected to be the same as `water_well_nums`,
    ## otherwise error will be raised by `get_full_calib_data`
    # k4dcv_bydye = OrderedDict(map(cd_key_vec) do cd_key
    #    k_data_1dye, dcv_well_nums = dcv_data_dict[cd_key]
    #    return cd_key => k_data_1dye .- water_data
    # end)
    #
    ## subtract water calibration data
    const channel_nums = CHANNELS[1:calibration_data.num_channels]
    const dyes = [Symbol(CHANNEL_KEY * "_" * string(c)) for c in channel_nums]
    const water_data_2bt = reduce(hcat, calibration_data.water)
    #
    ## no information on well numbers in calibration info so make default assumptions
    const n_wells = size(water_data_2bt, 1)
    const water_well_nums = collect(1:n_wells)
    #
    ## vectorized
    # water_data = transpose(reduce(hcat,calib_data[WATER_KEY][FLUORESCENCE_VALUE_KEY]))
    # k4dcv_bydye = OrderedDict(map(channel_nums) do channel
    #     signal_data = transpose(reduce(hcat, calib_data[dyes[channel]][FLUORESCENCE_VALUE_KEY]))
    #     return dyes[channel] => signal_data .- water_data
    # end)
    ## devectorized
    const k4dcv_bydye = OrderedDict(
        map(channel_nums) do c
            const signal_data_2bt = reduce(hcat, getfield(calibration_data, dyes[c]))
            const k4dcv_c ::Array{Float_T,2} =
                [   signal_data_2bt[i,j] - water_data_2bt[i,j]
                    for j in channel_nums, i in 1:n_wells       ]
            dyes[c] => k4dcv_c
        end) ## do c
    #
    ## check that the water-subtracted signal in the target channel
    ## is greater than that in the non-target channel(s) for each well and each dye
    err_msgs = Vector{String}()
    for target_channel_i in channel_nums
        const target_signals = view(k4dcv_bydye[dyes[target_channel_i]], target_channel_i, :)
        for non_target_channel_i in channel_nums
            if (target_channel_i != non_target_channel_i)
                non_target_signals = view(k4dcv_bydye[dyes[target_channel_i]], non_target_channel_i, :)
                failed_idc = find(target_signals .<= non_target_signals)
                if length(failed_idc) > 0
                    push!(err_msgs,
                        "invalid deconvolution data for the dye targeting channel $target_channel_i: " *
                        "fluorescence value of non-target channel $non_target_channel_i " *
                        "is greater than or equal to that of target channel $target_channel_i " *
                        "in the following well(s) - " * join(water_well_nums[failed_idc], ", "))
                end ## if
            end ## if
        end ## for non_target_channel_i
    end ## for channel_i
    (length(err_msgs) > 0) && throw(DomainError(join(err_msgs, "; ")))
    #
    ## compute inverses and return
    const INV_NOTE_PT2 = ": K matrix is singular, using `pinv` instead of `inv` " *
    "to compute inverse matrix of K. Deconvolution result may not be accurate. " *
    "This may be caused by using the same or a similar set of solutions " *
    "in the steps for different dyes."
    const (k_s, k_inv_vec, inv_note) =
        calc_kinv(Val{well_proc}, k4dcv_bydye, dyes, n_wells, water_well_nums)
    const k4dcv = K4Deconv(k_s, k_inv_vec, (length(inv_note) > 0 ? inv_note * INV_NOTE_PT2 : ""))
    (length(save_to) > 0) && save(save_to, "k4dcv", k4dcv)
    return k4dcv
end ## get_k()


#=============================================================================================#


## dependencies of get_k() >>

function calc_kinv(
    ::Type{Val{well_proc_mean}},
    k4dcv_bydye     ::Associative,
    dyes            ::AbstractVector,
    n_wells         ::Integer,
    water_well_nums ::AbstractVector
)
    inv_note = false
    const k_s =
        mapreduce( ## `cd` - channel of dye
            cd_key -> Array{Float_T}(sweep(sum)(/)(mean(k4dcv_bydye[cd_key], 2))),
            hcat,
            dyes)
    const k_inv = try
        inv(k_s)
    catch err
        if isa(err, Base.LinAlg.SingularException)
            inv_note = true
            pinv(k_s)
        else
            rethrow(err)
        end ## if isa(err,
    end ## try
    return k_s, fill(k_inv, n_wells), inv_note ? "" : "Well mean"
end

function calc_kinv(
    ::Type{Val{well_proc_vec}},
    k4dcv_bydye     ::Associative,
    dyes            ::AbstractVector,
    n_wells         ::Integer,
    water_well_nums ::AbstractVector
)
    singular_well_nums = Vector{Int}()
    const k_s =
        [   mapreduce(
                cd_key -> Array{Float_T}(sweep(sum)(/)(k4dcv_bydye[cd_key][:, i])),
                hcat,
                dyes)
            for i in 1:n_wells   ]
    const k_inv_vec =
        [   try
                inv(k_s[i])
            catch err
                if isa(err, Union{Base.LinAlg.SingularException, Base.LinAlg.LAPACKException})
                    push!(singular_well_nums, water_well_nums[i])
                    pinv(k_s[i])
                else
                    rethrow(err)
                end ## if isa(err
            end ## try
            for i in 1:n_wells   ]
    const inv_note = (length(singular_well_nums) > 0) ?
        "Well(s) " * string(join(singular_well_nums, ", ")) : ""
    return k_s, k_inv_vec, inv_note
end


#=============================================================================================#


## unused function
# function calib_calib(
#     ## remove MySql dependency
#     #
#     # db_conn_1 ::MySQL.MySQLHandle,
#     # db_conn_2 ::MySQL.MySQLHandle,
#     # calib_info_1 ::OrderedDict,
#     # calib_info_2 ::OrderedDict,
#     # well_nums_1 ::AbstractVector=[],
#     # well_nums_2 ::AbstractVector=[];
#     dye_in      ::Symbol =:FAM,
#     dyes_to_fill ::AbstractVector =[]
# )
#     ## This function is expected to handle situations where `calib_info_1` and `calib_info_2`
#     ## have different combinations of wells, but the number of wells should be the same.
#     if length(well_nums_1) != length(well_nums_2)
#         throw(DimensionMismatch("length(well_nums_1) != length(well_nums_2)"))
#     end

#     ## remove MySql dependency
#     #
#     # calib_dict_1 = get_full_calib_data(db_conn_1, calib_info_1, well_nums_1)
#     # water_well_nums_1 = calib_dict_1["water"][2]
#     #
#     # calib_key_vec_1 = get_ordered_keys(calib_info_1)
#     # cd_key_vec_1 = calib_key_vec_1[2:end] ## cd = channel of dye. "water" is index 1 per original order.
#     # channel_nums_1 = map(cd_key_vec_1) do cd_key
#     #     parse(Int, split(cd_key, "_")[2])
#     # end
#
#     const ary2dcv_1 =
#         cat(1,
#             map(values(calib_dict_1)) do value_1
#                 reshape(transpose(fluo_data), 1, size(value_1[1])[2:-1:1]...)
#             end...) ## do value_1
#     const (background_subtracted_data_1, k4dcv_2, deconvoluted_data_1, norm_data_2, norm_well_nums_2, calibrated_data_1) =
#         calibrate(
#             ary2dcv_1,
#             db_conn_2,
#             calib_info_2,
#             well_nums_2,
#             well_nums_2,
#             channel_nums_1,
#             true,
#             dye_in,
#             dyes_to_fill;
#             data_format = array)
#     return CalibCalibOutput(
#         ary2dcv_1,
#         background_subtracted_data_1,
#         k4dcv_2,
#         deconvoluted_data_1,
#         norm_data_2,
#         calibrated_data_1)
# end ## calib_calib


## deprecated to remove MySql dependency
#
## get all the data from a calibration experiment, including data from all the channels for all the steps
# function get_full_calib_data(
#    db_conn::MySQL.MySQLHandle,
#    calib_info::OrderedDict,
#    well_nums::AbstractVector=[]
#    )
#
#    calib_info = ensure_ci(db_conn, calib_info)
#
#    calib_key_vec = get_ordered_keys(calib_info)
#    cd_key_vec = calib_key_vec[2:end] ## cd = channel of dye. "water" is index 1 per original order.
#    channel_nums = map(cd_key_vec) do cd_key
#        parse(Int, split(cd_key, "_")[2])
#    end
#    num_channels = length(channel_nums)
#
#    calib_dict = OrderedDict(map(calib_key_vec) do calib_key
#        exp_id = calib_info[calib_key]["calibration_id"]
#        step_id = calib_info[calib_key]["step_id"]
#        k_qry_2b = "
#            SELECT fluorescence_value, well_num, channel
#                FROM fluorescence_data
#                WHERE
#                    experiment_id = $exp_id AND
#                    step_id = $step_id AND
#                    cycle_num = 1 AND
#                    step_id is not NULL
#                    well_constraint
#                ORDER BY well_num, channel
#        "
#        calib_data_1key, calib_well_nums = get_mysql_data_well(
#            well_nums, k_qry_2b, db_conn, false
#        )
#        if length(well_nums) > 0 && Set(calib_well_nums) != Set(well_nums)
#            error(logger, "experiment $exp_id, step $step_id: calibration data is not found for all the wells requested")
#        end ## if
#        calib_data_1key_chwl = vcat(map(channel_nums) do channel
#            transpose(calib_data_1key[:fluorescence_value][calib_data_1key[:channel] .== channel])
#        end...) ## do channel. return an array where rows indexed by channels and columns indexed by wells
#
#        return calib_key => (calib_data_1key_chwl, calib_well_nums)
#    end)
#
#    return calib_dict ## share the same keys as `calib_info`
#
# end ## get_full_calib_data
