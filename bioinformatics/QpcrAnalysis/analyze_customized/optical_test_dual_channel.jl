## optical_test_dual_channel.jl

import DataStructures.OrderedDict
import JSON.json


function act(
    ::OpticalTestDualChannel,
    ## remove MySqldependency
    #
    # db_conn ::MySQL.MySQLHandle,
    # exp_id ::Integer,
    # calib_info ::Union{Integer,OrderedDict}; # keys: "baseline", "water", "channel_1", "channel_2". Each value's "calibration_id" value is the same as `exp_id`
    #
    # start: arguments that might be passed by upstream code
    # well_nums ::AbstractVector =[],
    ot_dict         ::Associative; # keys: "baseline", "water", "FAM", "HEX"
    out_format      ::Symbol = :pre_json,
    verbose         ::Bool =false
)
    function SNR_test(w, cl)
        const baseline_2chs, water_fluo_2chs, signal_fluo_2chs =
            map([:baseline, :water, cl]) do key
                fluo_dict[key][w, :]
            end
        const snr_2chs = (signal_fluo_2chs .- water_fluo_2chs) ./ (signal_fluo_2chs .- baseline_2chs)
        transpose(dscrmnts_snr[cl](transpose(snr_2chs)))
    end

    ## remove MySql dependency
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

    # fluo_dict = OrderedDict(map(old_calib_labels) do calib_label # old
    const fluo_dict =
        OrderedDict(
            map(1:length(OLD_CALIB_SYMBOLS)) do calib_label_i
                OLD_CALIB_SYMBOLS[calib_label_i] =>
                    mapreduce(
                        ## old
                        # fluo_data[:fluorescence_value][
                        #     (fluo_data[:step_id] .== calib_info[calib_label]["step_id"]) .& (fluo_data[:channel] .== channel)
                        # ]
                        channel -> ot_dict[string(NEW_CALIB_SYMBOLS[calib_label_i])][
                            "fluorescence_value"][channel],
                        hcat,
                        CHANNELS)
            end)
    const num_wells = size(fluo_dict[:baseline], 1)
    bool_dict = OrderedDict(:baseline => fill(true, num_wells, length(CHANNELS)))
    ## water test
    bool_dict[:water] =
        mapreduce(
            channel_i ->
                map(fluo_dict[:water][:, channel_i]) do fluo_pw
                    WATER_MIN[channel_i] < fluo_pw < WATER_MAX[channel_i]
                end,
            hcat,
            CHANNEL_IS)
    ## FAM and HEX SNR test
    for calib_label in CALIB_SYMBOLS_FAM_HEX
        bool_dict[calib_label] =
            mapreduce(
                well_i -> SNR_test(well_i, calib_label),
                vcat,
                1:num_wells)
    end
    ## organize "optical_data"
    const optical_data =
        map(1:num_wells) do well_i
            OrderedDict(
                map(1:length(OLD_CALIB_SYMBOLS)) do cl_i
                    NEW_CALIB_SYMBOLS[cl_i] =>
                        map(channel_i ->
                                (fluo_dict[OLD_CALIB_SYMBOLS[cl_i]][well_i, channel_i],
                                    bool_dict[OLD_CALIB_SYMBOLS[cl_i]][well_i, channel_i]),
                            CHANNEL_IS)
                end) # do cl_i
        end # do well_i
    ## FAM and HEX self-calibrated
    ## ((signal_of_dye_x_in_channel_k - water_in_channel_k) /
    ##     (signal_of_target_dye_in_channel_k - water_in_channel_k); x=FAM,HEX; k=1,2)
    ## ratio (self_calib_of_dye_x_where_k_equals_1 / self_calib_of_dye_x_where_k_equals_2) test.
    #
    ## Note:
    ## Baseline is not subtracted because it is not part of the calibration procedure.
    #
    ## Issues:
    ## Is it more sensible to calculate target:off-target ratio than channel_1:channel_2?
    ## Calculation of ratio may fail if water >= signal values,
    ## reporting negative or infinite values
    #
    ## substract water values from signal values
    const swd_vec =
        map(CALIB_SYMBOLS_FAM_HEX) do calib_label
            map(CHANNEL_IS) do channel_i
                fluo_dict[calib_label][:, channel_i] .- fluo_dict[:water][:, channel_i]
            end # do channel_i
        end # do calib_label
    ## calculate normalization values from data in target channels
    const swd_normd =
        map(CHANNEL_IS) do channel_i
            sweep(mean)(/)(swd_vec[channel_i][channel_i])
        end # do channel_i
    ## normalize signal data
    const self_calib_vec =
        map(swd_vec) do swd_dye
            map(CHANNEL_IS) do channel_i
                swd_dye[channel_i] ./ swd_normd[channel_i]
            end # do channel_i
        end # do swd_dye
    ## raise an error if there are negative or zero values in the normalized data
    ## that will cause the channel1:channel2 ratio to be zero, infinite, or negative
    ## vectorized
    # if self_calib_vec |> mapreduce[mapreduce[mapreduce[broadcast[>=,0.0],|],|],|]
    #     error("Zero or negative values in the self-calibrated fluorescence data.")
    # end
    ## devectorized
    for dye in CHANNEL_IS, channel in CHANNEL_IS
        if any(self_calib_vec[dye][channel] .<= 0.0)
            error("Zero or negative values in the self-calibrated fluorescence data.")
        end
    end
    ## calculate channel1:channel2 ratios
    const ch12_ratios =
        OrderedDict(
            map(CHANNEL_IS) do channel_i
                sc_dye = self_calib_vec[channel_i]
                [:FAM, :HEX][channel_i] => round.(sc_dye[1] ./ sc_dye[2], JSON_DIGITS)
            end) # do channel_i
    ## format output
    const output = OrderedDict(
        optical_data        => optical_data,
        Symbol("Ch1:Ch2")   => ch12_ratios,
        :valid              => true)
    return (out_format == :json) ?
        JSON.json(output) :
        output
end # analyze_optical_test_dual_channel()




#