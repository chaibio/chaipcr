# optical calibration

# old pre-defined (predfd) step ids for calibration data
const oc_water_step_id_PREDFD = 2
const oc_signal_step_ids_PREDFD = OrderedDict(1=>4, 2=>4)

# mapping from factory to user dye data
# db_name_ = "20160406_chaipcr"
const PRESET_calib_ids = OrderedDict(
    "water" => 114,
    "signal" => OrderedDict("FAM"=>115, "HEX"=>116, "JOE"=>117)
)
const DYE2CHST = OrderedDict( # mapping from dye to channel and step_id.
    "FAM" => OrderedDict("channel"=>1, "step_id"=>266),
    "HEX" => OrderedDict("channel"=>2, "step_id"=>268),
    "JOE" => OrderedDict("channel"=>2, "step_id"=>270)
)


# types

immutable Ccsc # channels_check_subset_composite
    set::Vector # channels
    description::String
end


# process preset calibration data

const DYE2CHST_channels = Vector{Int}(unique(map(
    dye_dict -> dye_dict["channel"],
    values(DYE2CHST)
))) # change type from Any to Int (8e-6 to 13e-6 sec on PC)

const DYE2CHST_ccsc = Ccsc(DYE2CHST_channels, "all channels in the preset well-to-well variation data")


# functions

# Top-level function: adjust well-to-well variation in absolute fluorescence values (w2wvaf). wva = w2wva. aw = adj_w2wvaf.
# basic difference: w2wvaf/wva/aw - only used for `adj_w2wvaf`, each dye only has data for its target channel; calibration/calib/oc - used for `deconv` and `adj_w2wvaf`, each dye has data for both target and non-target channels.
# Input `fluo` and output: dim1 indexed by well and dim2 indexed by unit, which can be cycle (amplification) or temperature point (melt curve).
# Output does not include the automatically created column at index 1 from rownames of input array as R does
function adj_w2wvaf(
    fluo2btp::AbstractArray,
    wva_data::OrderedDict, wva_well_idc_wfluo::AbstractVector,
    channel::Integer;
    minus_water::Bool=false,
    scaling_factor_adj_w2wvaf::Real=SCALING_FACTOR_adj_w2wvaf
    )

    fluo = transpose(fluo2btp)

    wva_water, wva_signal = map(["water", "signal"]) do wva_type
        wva_data[wva_type][channel][wva_well_idc_wfluo]
    end # do oc_type

    if !minus_water
        wva_water = 0
    end # if

    signal_water_diff = wva_signal .- wva_water
    swd_normd = signal_water_diff ./ mean(signal_water_diff)

    fluo_aw_vec = map(1:size(fluo)[2]) do i
        scaling_factor_adj_w2wvaf .* (fluo[:,i] .- wva_water) ./ swd_normd
    end # do i

    return transpose(hcat(fluo_aw_vec...))

end # adj_w2wvaf


# functions called by `adj_w2wvaf`


# function: check subset
function check_subset(small::Ccsc, big::Ccsc)
    if length(setdiff(small.set, big.set)) != 0
        error("$(small.description) is not a subset of $(big.description). ")
    end
end


# to be deprecated to remove dependency on MySQL
# function: get well-to-well variation data well-to-well variation in absolute fluorescence (wva)
function get_wva_data(
    # calib_id_s and step_id_s as OrderedDict are expected to be OrderedDict{T,T} where T <: Integer
    calib_id_s::Union{Integer,OrderedDict},
    step_id_s::Union{Integer,OrderedDict},
    db_conn::MySQL.MySQLHandle,
    calib_id_key_isa::String, # "channel" or "dye"
    well_nums::AbstractVector
    )

    step_id_s_uniq = isa(step_id_s, Integer) ? unique(step_id_s) : unique(values(step_id_s))
    len_step_id_s_uniq = length(step_id_s_uniq)

    if isa(calib_id_s, Integer) && len_step_id_s_uniq == 1
        calib_id = calib_id_s
        step_id = step_id_s_uniq[1]
        calib_qry_2b =  "
            SELECT fluorescence_value, well_num, channel
                FROM fluorescence_data
                WHERE
                    experiment_id = $calib_id AND
                    step_id = $step_id AND
                    cycle_num = 1 AND
                    step_id is not NULL
                    well_constraint
                ORDER BY well_num, channel
        "
        calib_nt, complete_well_nums = get_mysql_data_well(
            well_nums, calib_qry_2b, db_conn, false)
        calib_id_key_vec = channels_in_df = unique(calib_nt[:channel])
        wva_vecs_byky = map(channels_in_df) do channel_in_df
            wva_vec = map(
                AbstractFloat, # integer values may cause type issues for downstream computation
                calib_nt[:fluorescence_value][calib_nt[:channel] .== channel_in_df]
            )
            return wva_vec
        end # do channel_in_df

    elseif !isa(calib_id_s, Integer) || len_step_id_s_uniq > 1

        calib_id_key_vec = get_ordered_keys(step_id_s)

        if isa(calib_id_s, Integer) && len_uniq_step_id_s > 1
            calib_id_s = OrderedDict([calib_id_key => calib_id_s for calib_id_key in calib_id_key_vec])
        end

        wva_vecs_byky = Array{Array{AbstractFloat,1},1}()
        well_nums_dupd = Vector{Vector}()
        for calib_id_key in calib_id_key_vec
            if calib_id_key_isa == "channel" # String
                channel = calib_id_key
            elseif calib_id_key_isa == "dye" #
                channel = DYE2CHST[calib_id_key]["channel"]
            else
                error("If multipe experiments are used for calibration, `calib_id_key_isa` needs to be \"channel\" or \"dye\". ")
            end
            wva_qry_2b = "
                SELECT fluorescence_value, well_num
                FROM fluorescence_data
                WHERE
                    experiment_id = $(calib_id_s[calib_id_key]) AND
                    step_id = $(step_id_s[calib_id_key]) AND
                    channel = $channel AND
                    cycle_num = 1 AND
                    step_id is not NULL
                    well_constraint
                ORDER BY well_num
            "
            wva_nt, found_well_nums = get_mysql_data_well(
                well_nums, wva_qry_2b, db_conn, false)
            push!(wva_vecs_byky, wva_nt[:fluorescence_value])
            push!(well_nums_dupd, found_well_nums)
        end
        complete_well_nums = intersect(well_nums_dupd...)

    else # len_step_id_s_uniq < 1
        error("Lengths of `calib_id_s` and `step_id_s` need to be greater than 0. ")

    end # if

    if length(well_nums) > length(complete_well_nums) # not use `setdiff` because `well_nums` may be `[]` to select all available wells
        error("Calibration data are not complete for these wells: $(join(setdiff(well_nums, complete_well_nums), ", ")). ")
    end

    wva_data_dict = OrderedDict([
        calib_id_key_vec[i] => wva_vecs_byky[i]
        for i in 1:length(calib_id_key_vec)
    ])

    return wva_data_dict, calib_id_key_vec, complete_well_nums # Tuple{DataStructures.OrderedDict{Any,Any}, DataArrays.DataArrays{Int8,1}, DataArrays.DataArray{Int32,1} }

end # get_wva_data


# function: check whether the data in optical calibration experiment is valid; if yes, prepare calibration data
function prep_adj_w2wvaf(
    # db_conn::MySQL.MySQLHandle,
    # calib_info::Union{Integer,OrderedDict}, # can be an interger or a OrderedDict in chai format: OrderedDict("water"=OrderedDict(calibration_id=>..., step_id=>...), "channel_1"=OrderedDict(calibration_id=..., step_id=...), "channel_2"=OrderedDict(calibration_id=...", step_id=...).
    calib_data::AbstractArray, # new
    well_nums::AbstractVector,
    dye_in::String="FAM",
    dyes_2bfild::AbstractVector=[]
    )

    calib_info = ensure_ci(db_conn, calib_info)

    if isa(calib_info, Integer) # `calib_info` is an integer. Using `oc_water_step_id` and `oc_signal_step_ids` defined outside of this function
        water_calib_id  = signal_calib_id_s = calib_info
        # This operation caused oc_water_step_id and oc_signal_step_ids to be compiled as local variables in prep_optic_calib: define oc_water_step_id and oc_signal_step_ids in the module scope, use them in this `if` clause, then try to assign new values to them in the following `else` clause
        oc_water_step_id = oc_water_step_id_PREDFD
        oc_signal_step_ids = oc_signal_step_ids_PREDFD
    elseif isa(calib_info, OrderedDict)
        calib_id_key_vec = get_ordered_keys(calib_info) # will remain ["water", "channel_1", "channel_2"...]
        water_cs_dict = calib_info["water"]
        water_calib_id = water_cs_dict["calibration_id"]
        oc_water_step_id = water_cs_dict["step_id"]
        ci_channel_key_vec = calib_id_key_vec[find(calib_id_key_vec) do ci_key
            ci_key[1:2] == "ch"
        end] # ci = calib_info
        channel_vec = map(ci_channel_key_vec) do ci_channel_key
            parse(Int, split(ci_channel_key, "_")[2])
        end
        signal_calib_id_s = OrderedDict{Int,Int}()
        oc_signal_step_ids = OrderedDict{Int,Int}()
        for ci_channel_key in ci_channel_key_vec
            channel = parse(Int, split(ci_channel_key, "_")[2])
            signal_calib_id_s[channel] = calib_info[ci_channel_key]["calibration_id"]
            oc_signal_step_ids[channel] = calib_info[ci_channel_key]["step_id"]
        end
    end

    water_data_dict, channels_in_water, water_well_nums = get_wva_data(water_calib_id, oc_water_step_id, db_conn, "", well_nums)
    check_subset(Ccsc(channels_in_water, "Input water channels"), DYE2CHST_ccsc)

    signal_data_dict, channels_in_signal, signal_well_nums = get_wva_data(signal_calib_id_s, oc_signal_step_ids, db_conn, "channel", well_nums)
    check_subset(Ccsc(channels_in_signal, "Input signal channels"), DYE2CHST_ccsc)

    if water_well_nums != signal_well_nums
        error("The wells with water data ($(join(water_well_nums, ", "))) are not the same as those with signal data ($(join(signal_well_nums, ", "))). ")
    end

    # check data length
    water_lengths = map(length, channels_in_water)
    signal_lengths = map(length, channels_in_signal)
    if length(unique([water_lengths; signal_lengths])) > 1
        error("Data lengths are not equal across all the channels and/or between water and signal. Water: $water_lengths. Signal: $signal_lengths. ")
    end

    # check whether signal fluo > water fluo
    stop_msgs = Vector{String}()
    for channel_in_signal in channels_in_signal
        wva_invalid_idc = find(
            signal_minus_water -> signal_minus_water <= 0, signal_data_dict[channel_in_signal] .- water_data_dict[channel_in_signal]
        )
        if length(wva_invalid_idc) > 0
            failed_well_nums_str = join(signal_well_nums[wva_invalid_idc], ", ")
            push!(stop_msgs,
                "Invalid well-to-well variation data in channel $channel_in_signal: fluorescence value of water is greater than or equal to that of dye in the following well(s) - $failed_well_nums_str. "
            )
        end # if
    end # for
    if (length(stop_msgs) > 0)
        error(join(stop_msgs, ""))
    end


    if length(dyes_2bfild) > 0 # extrapolate well-to-well variation data for missing channels

        println("Preset well-to-well variation data is used to extrapolate calibration data for missing channels.")

        channels_missing = setdiff(channels_in_water, channels_in_signal)
        dyes_2bfild_channels = map(dye -> DYE2CHST[dye]["channel"], dyes_2bfild) # DYE2CHST is defined in module scope
        check_subset(
            Ccsc(channels_missing, "Channels missing well-to-well variation data"),
            Ccsc(dyes_2bfild_channels, "channels corresponding to the dyes of which well-to-well variation data is needed")
        )

        # process preset calibration data
        preset_step_ids = OrderedDict([
            dye => DYE2CHST[dye]["step_id"]
            for dye in keys(DYE2CHST)
        ])
        preset_signal_data_dict, dyes_in_preset = get_wva_data(PRESET_calib_ids["signal"], preset_step_ids, db_conn, "dye") # `well_nums` is not passed on

        pivot_preset = preset_signal_data_dict[dye_in]

        pivot_in = signal_data_dict[DYE2CHST[dye_in]["channel"]]

        in2preset = pivot_in ./ pivot_preset

        for dye_2bfild in dyes_2bfild
            signal_data_dict[DYE2CHST[dye_2bfild]["channel"]] = preset_signal_data_dict[dye_2bfild] .* in2preset
        end

    end # if

    wva_data = OrderedDict(
        "water" => water_data_dict,
        "signal" => signal_data_dict
    ) # water_data and signal_data are OrderedDict objects keyed by channels, to accommodate the situation where calibration data has more channels than experiment data, therefore calibration data need to be easily subsetted by channel.

    return (wva_data, signal_well_nums)

end # prep_adj_w2wvaf




#
