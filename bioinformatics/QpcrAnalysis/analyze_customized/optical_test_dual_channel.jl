# chaipcr/web/public/dynexp/optical_test_dual_channel/analyze.R

# constants

const CHANNELS = [1, 2]
const CHANNEL_IS = 1:length(CHANNELS)
const CALIB_LABELS_FAM_HEX = map(channel -> "channel_$channel", CHANNELS)

# bounds of signal-to-noise ratio (SNR)
const SNR_FAM_CH1_MIN = 0.75
const SNR_FAM_CH2_MAX = 1
const SNR_HEX_CH1_MAX = 0.50
const SNR_HEX_CH2_MIN = 0.88

# fluo values: channel 1, channel 2
const WATER_MAX = [32000, 5000]
const WATER_MIN = [1000, -1000]


# signal-to-noise ratio discriminant functions for each well
dscrmnt_snr_fam(snr_2chs) = [snr_2chs[1] > SNR_FAM_CH1_MIN, snr_2chs[2] < SNR_FAM_CH2_MAX]
dscrmnt_snr_hex(snr_2chs) = [snr_2chs[1] < SNR_HEX_CH1_MAX, snr_2chs[2] > SNR_HEX_CH2_MIN]
const dscrmnts_snr = OrderedDict(map(1:2) do i
    CALIB_LABELS_FAM_HEX[i] => [dscrmnt_snr_fam, dscrmnt_snr_hex][i]
end) # do i


# analyze function
function analyze_func(
    ::OpticalTestDualChannel,
    # db_conn::MySQL.MySQLHandle,
    # exp_id::Integer,
    # calib_info::Union{Integer,OrderedDict}; # keys: "baseline", "water", "channel_1", "channel_2". Each value's "calibration_id" value is the same as `exp_id`
    # # start: arguments that might be passed by upstream code
    # well_nums::AbstractVector=[],
    exp_data::AbstractArray
    )

    fluo_qry_2b = "SELECT step_id, well_num, fluorescence_value, channel
        FROM fluorescence_data
        WHERE experiment_id = $exp_id AND cycle_num = 1 AND step_id is not NULL
        well_constraint
        ORDER BY well_num, channel
    "
    fluo_data, fluo_well_nums = get_mysql_data_well(
        well_nums, fluo_qry_2b, db_conn, false
    )

    num_wells = length(fluo_well_nums)

    old_calib_labels = ["baseline"; "water"; CALIB_LABELS_FAM_HEX]

    fluo_dict = OrderedDict(map(old_calib_labels) do calib_label
        calib_label => hcat(map(CHANNELS) do channel
            fluo_data[:fluorescence_value][
                (fluo_data[:step_id] .== calib_info[calib_label]["step_id"]) .& (fluo_data[:channel] .== channel)
            ]

        end...) # do channel
    end) # do calib_label

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
    new_calib_labels = ["baseline", "water", "FAM", "HEX"]
    optical_data = map(1:num_wells) do well_i
        OrderedDict(map(1:length(old_calib_labels)) do cl_i
            old_calib_label = old_calib_labels[cl_i]
            new_calib_labels[cl_i] => map(CHANNEL_IS) do channel_i
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


    return json(OrderedDict("optical_data"=>optical_data, "Ch1:Ch2"=>ch12_ratios))

end # analyze_optical_test_dual_channel
