## calibration.jl
##
## calibration procedure:
## 1. multichannel deconvolution
## 2. adjust well-to-well variation in absolute fluorescence values

import DataStructures.OrderedDict
import Memento: debug, error


## function definitions >>

## function: perform deconvolution and adjust well-to-well variation in absolute fluorescence
function calibrate(
    raw_data                ::AbstractArray,        ## array of raw fluorescence by cycle, well, channel
    dcv                     ::Bool,                 ## signal to perform multi-channel deconvolution
    channel_nums            ::AbstractVector,       ## vector of channel numbers
    ## remove MySql dependency
    # db_conn ::MySQL.MySQLHandle, ## `db_conn_default` is defined in "__init__.jl"
    # calib_info ::Union{Integer,OrderedDict},
    # well_nums_found_in_fr ::AbstractVector,
    # well_nums_in_req ::AbstractVector=[],
    calib_data              ::Associative,          ## calibration dataset
    well_nums_found_in_fr   ::AbstractVector,       ## vector of well numbers
    dye_in                  ::Symbol = :FAM,
    dyes_to_be_filled       ::AbstractVector =[];
    out_format              ::Symbol = :both        ## :array, :dict, :both
)
    debug(logger, "at calibrate()")

    ## remove MySql dependency
    # calib_info = ensure_ci(db_conn, calib_info)
    # norm_data, norm_well_nums = prep_normalize(db_conn, calib_info, well_nums_in_req, dye_in, dyes_to_be_filled)

    ## assume without checking that we are using all the wells, all the time
    const well_nums_in_req = calib_data |> num_wells |> from(0) |> collect
    #
    ## prepare data to adjust well-to-well variation in absolute fluorescence values
    const (norm_data, norm_well_nums) =
        prep_normalize(calib_data, well_nums_in_req, dye_in, dyes_to_be_filled)
    #
    ## overwrite the dummy well_nums
    norm_well_nums = well_nums_found_in_fr
    #
    const num_channels = length(channel_nums)
    # if length(well_nums_found_in_fr) == 0
    #     well_nums_found_in_fr = norm_well_nums
    # end

    ## remove MySql dependency
    #
    # matched_well_idc = find(norm_well_nums) do norm_well_num
    #     norm_well_num in well_nums_found_in_fr
    # end ## do norm_well_num

    ## issue:
    ## we can't match well numbers between calibration data and experimental data
    ## because we don't have that information for the calibration data
    const matched_well_idc = norm_well_nums |> length |> from(1) |> collect
    debug(logger, repr(matched_well_idc))

    ## subtract background
    ## mw = minus water
    const background_subtracted_data =
        cat(3,
            ## devectorized code avoids transposition
            [
                [   raw_data[u,w,c] - norm_data[:water][c][matched_well_idc][w]
                    for u in 1:size(raw_data, 1),
                        w in matched_well_idc     ]
                for c in 1:num_channels                 ]...)

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
                calib_data,
                well_nums_in_req;
                out_format = :array)
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
                        channel_i;
                        minus_water = false)
            end) ## do channel_i

    ## format output
    ## the following line of code needs the keys of calibrated_dict to be in sort order
    calibrated_array() = cat(3, values(calibrated_dict)...)
    const calibrated_data =
        if      (out_format == :array)  tuple(calibrated_array())
        elseif  (out_format == :dict)   tuple(calibrated_dict)
        elseif  (out_format == :both)   tuple(calibrated_array(), calibrated_dict)
        else                            throw(ArgumentException(
                                            "`out_format` must be :array, :dict or :both"))
        end ## if
    return (background_subtracted_data, k4dcv, deconvoluted_data,
            norm_data, norm_well_nums, calibrated_data...)
end ## calibrate()


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
#     dyes_to_be_filled ::AbstractVector =[]
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
#             true,
#             channel_nums_1,
#             db_conn_2,
#             calib_info_2,
#             well_nums_2,
#             well_nums_2,
#             dye_in,
#             dyes_to_be_filled;
#             out_format = :array)
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
