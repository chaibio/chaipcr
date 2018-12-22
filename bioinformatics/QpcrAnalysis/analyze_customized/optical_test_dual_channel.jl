# optical_test_dual_channel.jl

import DataStructures.OrderedDict
import JSON.json


function act(
    ::OpticalTestDualChannel,

    # remove MySqldependency
    #
    # db_conn ::MySQL.MySQLHandle,
    # exp_id ::Integer,
    # calib_info ::Union{Integer,OrderedDict}; # keys: "baseline", "water", "channel_1", "channel_2". Each value's "calibration_id" value is the same as `exp_id`
    # 
    # start: arguments that might be passed by upstream code
    # well_nums ::AbstractVector =[],

    # new >>
    ot_dict ::Associative; # keys: "baseline", "water", "FAM", "HEX"
    out_format ::String ="pre_json",
    verbose ::Bool =false
    # << new
)

    # remove MySql dependency
    #
    # fluo_qry_2b = "SELECT step_id, well_num, fluorescence_value, channel
    #     FROM fluorescence_data
    #     WHERE experiment_id = $exp_id AND cycle_num = 1 AND step_id is not NULL
    #     well_constraint
    #     ORDER BY well_num, channel
    # "
    # fluo_data, fluo_well_nums = get_mysql_data_well(
    #     well_nums, fluo_qry_2b, db_conn, false
    # )
    #
    # num_wells = length(fluo_well_nums)

    # new >>
    # fluo_dict = OrderedDict(map(old_calib_labels) do calib_label # old
    fluo_dict = OrderedDict(map(1:length(OLD_CALIB_LABELS)) do calib_label_i
    # << new

        OLD_CALIB_LABELS[calib_label_i] => hcat(map(CHANNELS) do channel # use old labels internally

            # remove MySql dependency
            #
            # fluo_data[:fluorescence_value][
            #     (fluo_data[:step_id] .== calib_info[calib_label]["step_id"]) .& (fluo_data[:channel] .== channel)
            # ]

            # new >>
            ot_dict[NEW_CALIB_LABELS[calib_label_i]]["fluorescence_value"][channel]
            # << new

        end...) # do channel
    end) # do calib_label

    # new >>
    num_wells = size(fluo_dict["baseline"])[1]
    # << new

    bool_dict = OrderedDict("baseline" => fill(true, num_wells, length(CHANNELS)))

    # water test
    bool_dict["water"] = hcat(map(CHANNEL_IS) do channel_i
        map(fluo_dict["water"][:, channel_i]) do fluo_pw
            fluo_pw < WATER_MAX[channel_i] && fluo_pw > WATER_MIN[channel_i]
        end # do fluo_pw
    end...) # end

    # FAM and HEX SNR test
    for calib_label in CALIB_LABELS_FAM_HEX
        bool_dict[calib_label] = vcat(map(1:num_wells) do well_i
            baseline_2chs = fluo_dict["baseline"][well_i, :]
            signal_fluo_2chs = fluo_dict[calib_label][well_i, :] .- baseline_2chs
            water_fluo_2chs = fluo_dict["water"][well_i, :] .- baseline_2chs
            snr_2chs = (signal_fluo_2chs .- water_fluo_2chs) ./ signal_fluo_2chs
            transpose(dscrmnts_snr[calib_label](transpose(snr_2chs)))
        end...) # do well_i
    end # for

    # organize "optical_data"
    optical_data = map(1:num_wells) do well_i
        OrderedDict(map(1:length(OLD_CALIB_LABELS)) do cl_i
            old_calib_label = OLD_CALIB_LABELS[cl_i]
            NEW_CALIB_LABELS[cl_i] => map(CHANNEL_IS) do channel_i
                (fluo_dict[old_calib_label][well_i, channel_i], bool_dict[old_calib_label][well_i, channel_i])
            end # do channel_i
        end) # do cl_i
    end # do well_i

    # FAM and HEX self-calibrated ((signal_of_dye_x_in_channel_k - water_in_channel_k) / (signal_of_target_dye_in_channel_k - water_in_channel_k); x=FAM,HEX; k=1,2) ratio (self_calib_of_dye_x_where_k_equals_1 / self_calib_of_dye_x_where_k_equals_2) test. Baseline is not subtracted because it is not part of the calibration procedure.

    swd_vec = map(CALIB_LABELS_FAM_HEX) do calib_label
        map(CHANNEL_IS) do channel_i
            fluo_dict[calib_label][:, channel_i] .- fluo_dict["water"][:, channel_i]
        end # do channel_i
    end # do calib_label

    swd_normd = map(CHANNEL_IS) do channel_i
        swd_target = swd_vec[channel_i][channel_i]
        swd_target / mean(swd_target)
    end # do channel_i

    self_calib_vec = map(swd_vec) do swd_dye
        map(CHANNEL_IS) do channel_i
            swd_dye[channel_i] ./ swd_normd[channel_i]
        end # do channel_i
    end # do swd_dye

    ch12_ratios = OrderedDict(map(CHANNEL_IS) do channel_i
        sc_dye = self_calib_vec[channel_i]
        ["FAM", "HEX"][channel_i] => round.(sc_dye[1] ./ sc_dye[2], JSON_DIGITS)
    end) # do channel_i

    output = OrderedDict("optical_data" => optical_data, "Ch1:Ch2" => ch12_ratios)
    if (out_format=="json")
        return JSON.json(output)
    else
        return output
    end
    
end # analyze_optical_test_dual_channel




#      