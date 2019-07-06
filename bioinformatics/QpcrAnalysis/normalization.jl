## normalization.jl
##
## normalize variation between wells in absolute fluorescence values

import DataStructures.OrderedDict
import Memento: debug, error


## constants
const NORMALIZATION_SCALING_FACTOR  = 3.7           ## used: 9e5, 1e5, 1.2e6, 3.0
const DEFAULT_NORM_MINUS_WATER      = false
const DEFAULT_NORM_DYE_IN           = :FAM
const DEFAULT_NORM_DYES_TO_FILL     = []

## function definitions >>

## Top-level function: normalize variation between wells in absolute fluorescence values (normalize).
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
    channel                         ::Integer;
    minus_water                     ::Bool = DEFAULT_NORM_MINUS_WATER,
    normalization_scaling_factor    ::Real = NORMALIZATION_SCALING_FACTOR,
)
    debug(logger, "at normalize()")

    ## devectorized code avoids transposing data matrix
    if minus_water == false
        const swd = norm_data[:signal][channel][matched_well_idc]
        return ([
            normalization_scaling_factor * mean(swd) *
                fluorescence[i,w] / swd[w]
                    for i in 1:size(fluorescence, 1),
                        w in 1:size(fluorescence, 2)]) ## w = well
    end

    ## minus_water == true
    const norm_water = norm_data[:water][channel][matched_well_idc]
    const swd = norm_data[:signal][channel][matched_well_idc] .- norm_water
    return ([
        normalization_scaling_factor * mean(swd) *
            (fluorescence[i,w] - norm_water[w]) / swd[w]
                for i in 1:size(fluorescence, 1),
                    w in 1:size(fluorescence, 2)]) ## w = well
end ## normalize


## function: check whether the data in optical calibration experiment is valid
function prep_normalize(
    calibration_data    ::CalibrationData{C},
    well_nums           ::AbstractVector;
    dye_in              ::Symbol = DEFAULT_NORM_DYE_IN,
    dyes_to_fill        ::AbstractVector = DEFAULT_NORM_DYES_TO_FILL,
) where {C <: AbstractFloat}
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
        catch
            push!(stop_msgs, "Cannot access water calibration data for channel $channel")
        end ## try
        try
            signal_data_dict[channel] = getfield(calibration_data, key)[channel]
        catch
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
    const signal_well_nums = collect(1:length(signal_data_dict[1]))
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
