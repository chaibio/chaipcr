# calib.jl
#
# calibration: deconvolution and adjust well-to-well variation in absolute fluorescence values

using DataStructures.OrderedDict;

# scaling factors
const SCALING_FACTOR_deconv_vec = [1.0, 4.2] # used: [1, oneof(1, 2, 3.5, 8, 7, 5.6, 4.2)]
const SCALING_FACTOR_adj_w2wvaf = 3.7 # used: 9e5, 1e5, 1.2e6, 3




# function: perform deconvolution and adjust well-to-well variation in absolute fluorescence
function dcv_aw(
    fr_ary3 ::AbstractArray,
    dcv ::Bool,
    channel_nums ::AbstractVector,
    # arguments needed if `k_compute=true`

    ## remove MySql dependency
    #
    # db_conn ::MySQL.MySQLHandle, # `db_conn_default` is defined in "__init__.jl"
    # calib_info ::Union{Integer,OrderedDict},
    # well_nums_found_in_fr ::AbstractVector,
    # well_nums_in_req ::AbstractVector=[],

    # new >>
    calib_data ::OrderedDict{String,Any},
    well_nums_found_in_fr ::AbstractVector,
    # << new

    dye_in ::String ="FAM",
    dyes_2bfild ::AbstractVector =[];
    aw_out_format ::String ="both" # "array", "dict", "both"
    )

    ## remove MySql dependency
    #
    # calib_info = ensure_ci(db_conn, calib_info)
    #
    # wva_data, wva_well_nums = prep_adj_w2wvaf(db_conn, calib_info, well_nums_in_req, dye_in, dyes_2bfild)

    # new >>
    # not implemented yet
    calib_data = ensure_ci(calib_data)
    #
    # assume without checking that we are using all the wells, all the time
    well_nums_in_req = range(0,length(calib_data["water"]["fluorescence_value"][1]))
    #
    # prepare data to adjust well-to-well variation in absolute fluorescence values
    wva_data, wva_well_nums = prep_adj_w2wvaf(calib_data, well_nums_in_req, dye_in, dyes_2bfild)
    # << new

    num_channels = length(channel_nums)

    if length(well_nums_found_in_fr) == 0
        well_nums_found_in_fr = wva_well_nums
    end

    ## remove MySql dependency
    #
    # wva_well_idc_wfluo = find(wva_well_nums) do wva_well_num
    #     wva_well_num in well_nums_found_in_fr
    # end # do wva_well_num

    # new >>
    # we can't match well numbers between calibration data and experimental data
    # because we don't have that information for the calibration data
    wva_well_idc_wfluo = wva_well_nums
    # << new

    # subtract background
    # mw = minus water
    mw_ary3 = cat(3, map(1:num_channels) do channel_i
        fr_ary3[:,:,channel_i] .- transpose(
            wva_data["water"][channel_i][wva_well_idc_wfluo]
        )
    end...)

    if dcv

        ## this feature disabled while removing MySql dependency
        #
        ## addition with flexible ratio instead of deconvolution (commented out)
        ## k_inv_vec = fill(reshape(DataArray([1, 0, 1, 0]), 2, 2), 16) 
        #
        # k4dcv, dcvd_ary3 = deconV(
        #     1. * mw_ary3, channel_nums, wva_well_idc_wfluo, db_conn, calib_info, well_nums_in_req;
        #     out_format="array"
        # )

        # new >>
        # nothing implemented so use default
        k4dcv = K4DCV_EMPTY
        dcvd_ary3 = mw_ary3
        # << new

    else
        k4dcv = K4DCV_EMPTY
        dcvd_ary3 = mw_ary3
    end

    dcvd_aw_vec = map(1:num_channels) do channel_i
        adj_w2wvaf(
            dcvd_ary3[:,:,channel_i],
            wva_data,
            wva_well_idc_wfluo,
            channel_i;
            minus_water = false
        )
    end

    dcvd_aw_ary3 = Array{AbstractFloat}(cat(3, dcvd_aw_vec...))
    dcvd_aw_dict = OrderedDict(map(1:num_channels) do channel_i
        channel_nums[channel_i] => dcvd_aw_vec[channel_i]
    end) # do channel_i

    if aw_out_format == "array"
        dcvd_aw = (dcvd_aw_ary3,)
    elseif aw_out_format == "dict"
        dcvd_aw = (dcvd_aw_dict,)
    elseif out_format == "both"
        dcvd_aw = (dcvd_aw_ary3, dcvd_aw_dict)
    else
        error("`out_format` must be \"array\", \"dict\" or \"both\". ")
    end

    return (mw_ary3, k4dcv, dcvd_ary3, wva_data, wva_well_nums, dcvd_aw...)

end # dcv_aw


# perform deconvolution and adjustment of well-to-well variation on calibration experiment 1
# using the k matrix `wva_data` made from calibration experiment 2

type CalibCalibOutput
    ary2dcv_1 ::Array{AbstractFloat,3}
    mw_ary3_1 ::Array{AbstractFloat,3}
    k4dcv_2 ::K4Deconv
    dcvd_ary3_1 ::Array{AbstractFloat,3}
    wva_data_2 ::OrderedDict{String,OrderedDict{Int,AbstractVector}}
    dcv_aw_ary3_1 ::Array{AbstractFloat,3}
end

function calib_calib(

    ## remove MySql dependency
    #
    # db_conn_1 ::MySQL.MySQLHandle,
    # db_conn_2 ::MySQL.MySQLHandle,
    # calib_info_1 ::OrderedDict,
    # calib_info_2 ::OrderedDict,
    # well_nums_1 ::AbstractVector=[],
    # well_nums_2 ::AbstractVector=[];

    dye_in ::String="FAM", dyes_2bfild ::AbstractVector=[]
    )

    # This function is expected to handle situations where `calib_info_1` and `calib_info_2` have different combinations of wells, but the number of wells should be the same.
    if length(well_nums_1) != length(well_nums_2)
        error("length(well_nums_1) != length(well_nums_2). ")
    end

    ## remove MySql dependency
    #
    # calib_dict_1 = get_full_calib_data(db_conn_1, calib_info_1, well_nums_1)
    # water_well_nums_1 = calib_dict_1["water"][2]
    #
    # calib_key_vec_1 = get_ordered_keys(calib_info_1)
    # cd_key_vec_1 = calib_key_vec_1[2:end] # cd = channel of dye. "water" is index 1 per original order.
    # channel_nums_1 = map(cd_key_vec_1) do cd_key
    #     parse(Int, split(cd_key, "_")[2])
    # end

    ary2dcv_1 = cat(1, map(values(calib_dict_1)) do value_1
        fluo_data = value_1[1]
        num_channels, num_wells = size(fluo_data)
        reshape(transpose(fluo_data), 1, num_wells, num_channels)
    end...) # do value_1

    mw_ary3_1, k4dcv_2, dcvd_ary3_1, wva_data_2, wva_well_nums_2, dcv_aw_ary3_1 = dcv_aw(
        ary2dcv_1, true, channel_nums_1,
        db_conn_2, calib_info_2, well_nums_2, well_nums_2, dye_in, dyes_2bfild;
        aw_out_format="array"
    )

    return CalibCalibOutput(
        ary2dcv_1,
        mw_ary3_1,
        k4dcv_2,
        dcvd_ary3_1,
        wva_data_2,
        dcv_aw_ary3_1
    )

end # calib_calib



#
