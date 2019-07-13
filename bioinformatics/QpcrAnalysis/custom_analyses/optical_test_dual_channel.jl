#==============================================================================================

    optical_test_dual_channel.jl

==============================================================================================#

import DataStructures.OrderedDict
import Memento: debug, warn


#==============================================================================================
    constants >>
==============================================================================================#


## channel descriptors
const CHANNELS          = [1, 2]
const CHANNEL_IS        = eachindex(CHANNELS)
const SYMBOLS_FAM_HEX   = [:FAM, :HEX]
const NEW_CALIB_SYMBOLS = [:baseline; :water; SYMBOLS_FAM_HEX]

## preset values >>

## bounds of signal-to-noise ratio (SNR)
const SNR_FAM_CH1_MIN = 0.75
const SNR_FAM_CH2_MAX = 1
const SNR_HEX_CH1_MAX = 0.50
const SNR_HEX_CH2_MIN = 0.88

## signal-to-noise ratio discriminant functions for each well
dscrmnt_snr_fam(snr_2chs) = [snr_2chs[1] > SNR_FAM_CH1_MIN, snr_2chs[2] < SNR_FAM_CH2_MAX]
dscrmnt_snr_hex(snr_2chs) = [snr_2chs[1] < SNR_HEX_CH1_MAX, snr_2chs[2] > SNR_HEX_CH2_MIN]
const dscrmnts_snr = OrderedDict(map(1:2) do i
    SYMBOLS_FAM_HEX[i] => [dscrmnt_snr_fam, dscrmnt_snr_hex][i]
end) ## do i

## maximum and minimum fluorescence values: channel 1, channel 2
const WATER_MAX = [32000, 5000]
const WATER_MIN = [1000, -1000]


#==============================================================================================
    function definition >>
==============================================================================================#


## called by dispatch()
function act(
    ::Type{Val{optical_test_dual_channel}},
    ## remove MySqldependency
    #
    # db_conn ::MySQL.MySQLHandle,
    # exp_id ::Integer,
    # calib_info ::Union{Integer,OrderedDict}; ## keys: "baseline", "water", "channel_1", "channel_2". Each value's "calibration_id" value is the same as `exp_id`
    #
    # start: arguments that might be passed by upstream code
    # well_nums ::AbstractVector =[],
    ot_dict         ::Associative; ## keys: "baseline", "water", "FAM", "HEX"
    out_format      ::OutputFormat = pre_json_output
)
    function SNR_test(w, cl)
        const (baseline_2chs, water_fluo_2chs, signal_fluo_2chs) =
            map(key -> fluo_dict[key][w, :], [:baseline, :water, cl])
        const snr_2chs = (signal_fluo_2chs .- water_fluo_2chs) ./ (signal_fluo_2chs .- baseline_2chs)
        transpose(dscrmnts_snr[cl](transpose(snr_2chs)))
    end

    debug(logger, "at act(::Type{Val{optical_test_dual_channel}})")

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

    # fluo_dict = OrderedDict(map(old_calib_labels) do calib_label ## old
    const fluo_dict =
        OrderedDict(
            map(range(1, length(NEW_CALIB_SYMBOLS))) do calib_label_i
                NEW_CALIB_SYMBOLS[calib_label_i] =>
                    mapreduce(
                        ## old
                        # fluo_data[:fluorescence_value][
                        #     (fluo_data[:step_id] .== calib_info[calib_label]["step_id"]) .& (fluo_data[:channel] .== channel)
                        # ]
                        channel -> ot_dict[string(NEW_CALIB_SYMBOLS[calib_label_i])][FLUORESCENCE_VALUE_KEY][channel],
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
    for calib_label in SYMBOLS_FAM_HEX
        bool_dict[calib_label] =
            mapreduce(
                well_i -> SNR_test(well_i, calib_label),
                vcat,
                range(1, num_wells))
    end

    ## organize "optical_data"
    const optical_data =
        map(range(1, num_wells)) do well_i
            OrderedDict(
                map(range(1, length(NEW_CALIB_SYMBOLS))) do cl_i
                    NEW_CALIB_SYMBOLS[cl_i] =>
                        map(CHANNEL_IS) do channel_i
                            (fluo_dict[NEW_CALIB_SYMBOLS[cl_i]][well_i, channel_i],
                                bool_dict[NEW_CALIB_SYMBOLS[cl_i]][well_i, channel_i])
                        end ## do channel_i
                            
                end) ## do cl_i
        end ## do well_i

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
        map(SYMBOLS_FAM_HEX) do calib_label
            map(CHANNEL_IS) do channel_i
                fluo_dict[calib_label][:, channel_i] .- fluo_dict[:water][:, channel_i]
            end ## do channel_i
        end ## do calib_label
    ## calculate normalization values from data in target channels
    const swd_normd =
        map(CHANNEL_IS) do channel_i
            sweep(mean)(/)(swd_vec[channel_i][channel_i])
        end
    ## normalize signal data
    const self_calib_vec =
        map(swd_vec) do swd_dye
            map(CHANNEL_IS) do channel_i
                swd_dye[channel_i] ./ swd_normd[channel_i]
            end ## do channel_i
        end ## do swd_dye

    ## call as invalid aonalysis if there are negative or zero values in the normalized data
    ## that will cause the channel1:channel2 ratio to be zero, infinite, or negative
    ## devectorized
    error_msgs = Vector{String}()
    for dye in CHANNEL_IS, channel in CHANNEL_IS, value in self_calib_vec[dye][channel]
        if value <= 0.0
            ## call as invalid analysis instead of raising an error
            push!(error_msgs, "zero or negative values in the self-calibrated fluorescence data")
            warn(logger, error_msgs[end])
            break ## exit nested loops
        end ## if
    end ## for dye, channel, value
    #
    ## calculate channel1:channel2 ratios
    const ch12_ratios =
        OrderedDict(
            map(CHANNEL_IS) do channel_i
                sc_dye = self_calib_vec[channel_i]
                [:FAM, :HEX][channel_i] => round.(sc_dye[1] ./ sc_dye[2], JSON_DIGITS)
            end) # do channel_i
    if !(ch12_ratios |> values |> collect |> mold(x -> all(isfinite.(x))) |> all) ||
        (ch12_ratios |> values |> collect |> mold(x -> any(x .<= 0))      |> any)
            push!(error_msgs, "zero, negative, or infinite values of channel 1 : channel 2 ratio")
            warn(logger, error_msgs[end])
    end

    ## return values
    const output = OrderedDict(
        :optical_data       => optical_data,
        Symbol("Ch1:Ch2")   => ch12_ratios,
        :valid              => length(error_msgs) == 0,
        :error              => join(error_msgs, "; "))
    return output |> out(out_format)
end ## act(::Type{Val{optical_test_dual_channel}})
