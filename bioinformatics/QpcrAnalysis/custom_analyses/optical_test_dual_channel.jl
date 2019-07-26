#===============================================================================

    optical_test_dual_channel.jl

===============================================================================#

import DataStructures.OrderedDict
import StaticArrays.SVector
import Memento: debug, warn



#===============================================================================
    constants >>
===============================================================================#

## channel descriptors
const CHANNELS = DYES = SVector(1,2)
const DYE_SYMBOLS = SVector(:FAM, :HEX)
const OPTICAL_TEST_SYMBOLS = SVector(:baseline, :water, DYE_SYMBOLS...)

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
    DYE_SYMBOLS[i] => [dscrmnt_snr_fam, dscrmnt_snr_hex][i]
end) ## do i

## maximum and minimum fluorescence values: channel 1, channel 2
const WATER_MAX = [32000, 5000]
const WATER_MIN = [1000, -1000]



#===============================================================================
    function definition >>
===============================================================================#

## called by dispatch()
function act(
    ::Type{Val{optical_test_dual_channel}},
    req             ::Associative; ## keys: "baseline", "water", "FAM", "HEX"
    out_format      ::OutputFormat = pre_json_output
    ## remove MySqldependency
    #
    # db_conn ::MySQL.MySQLHandle,
    # exp_id ::Integer,
    # calib_info ::Union{Integer,OrderedDict}; ## keys: "baseline", "water", "channel_1", "channel_2". Each value's "calibration_id" value is the same as `exp_id`
    #
    # start: arguments that might be passed by upstream code
    # well_nums ::AbstractVector =[],
)
    function SNR_test(w, label)
        const (baseline_2chs, water_fluo_2chs, signal_fluo_2chs) =
            map(key -> fluo_dict[key][w, :], [:baseline, :water, label])
        const snr_2chs =
            (signal_fluo_2chs .- water_fluo_2chs) ./ (signal_fluo_2chs .- baseline_2chs)
        transpose(dscrmnts_snr[label](transpose(snr_2chs)))
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

    # fluo_dict = OrderedDict(map(old_labels) do label ## old
    const fluo_dict =
        OrderedDict(
            map(OPTICAL_TEST_SYMBOLS) do label
                label =>
                    mapreduce(
                        ## old
                        # fluo_data[:fluorescence_value][
                        #     (fluo_data[:step_id] .== calib_info[label]["step_id"]) .& (fluo_data[:channel] .== channel)
                        # ]
                        channel -> req[string(label)][FLUORESCENCE_VALUE_KEY][channel],
                        hcat,
                        CHANNELS)
            end)
    const num_wells = size(fluo_dict[:baseline], 1)
    #
    bool_dict = OrderedDict(:baseline => fill(true, num_wells, length(CHANNELS)))
    ## water test
    bool_dict[:water] =
        mapreduce(
            channel ->
                map(fluo_dict[:water][:, channel]) do fluo_pw
                    WATER_MIN[channel] < fluo_pw < WATER_MAX[channel]
                end,
            hcat,
            CHANNELS)
    ## FAM and HEX SNR test
    for label in DYE_SYMBOLS
        bool_dict[label] =
            mapreduce(
                well -> SNR_test(well, label),
                vcat,
                1:num_wells)
    end
    #
    ## organize "optical_data"
    const optical_data =
        map(1:num_wells) do well
            OrderedDict(
                map(OPTICAL_TEST_SYMBOLS) do label
                    label =>
                        map(CHANNELS) do channel
                            (fluo_dict[label][well, channel],
                                bool_dict[label][well, channel])
                        end ## do channel
                            
                end) ## do label
        end ## do well
    #
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
        map(DYE_SYMBOLS) do label
            map(CHANNELS) do channel
                fluo_dict[label][:, channel] .- fluo_dict[:water][:, channel]
            end ## do channel
        end ## do label
    ## calculate normalization values from data in target channels
    const swd_normd =
        map(CHANNELS) do target
            sweep(mean)(/)(swd_vec[target][target]) ## dye == channel
        end
    ## normalize signal data
    const self_calib_vec =
        map(swd_vec) do swd_dye
            map(CHANNELS) do channel
                swd_dye[channel] ./ swd_normd[channel]
            end ## do channel
        end ## do swd_dye
    #
    ## call as invalid analysis if there are negative or zero values in the normalized data
    ## that will cause the channel1:channel2 ratio to be zero, infinite, or negative
    ## devectorized
    error_msgs = Vector{String}()
    for dye in DYES, channel in CHANNELS, value in self_calib_vec[dye][channel]
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
            map(DYES) do dye
                sc_dye = self_calib_vec[dye]
                DYE_SYMBOLS[dye] => round.(sc_dye[1] ./ sc_dye[2], JSON_DIGITS)
            end) # do channel_i
    if !(ch12_ratios |> values |> mold(x -> all(isfinite.(x))) |> all) ||
        (ch12_ratios |> values |> mold(x -> any(x .<= 0))      |> any)
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
