## deconv.jl
## color compensation / multi-channel deconvolution

import DataStructures.OrderedDict

## multi-channel deconvolution
function deconvolute(
    ## ary2dcv dim1 is unit, which can be cycle (amplification), temperature point (melting curve),
    ## or step type (like "water", "channel_1", "channel_2" for calibration experiment);
    ## ary2dcv dim2 must be well, ary2dcv dim3 must be channel
    ary2dcv                 ::AbstractArray,

    ## must be the same length as 3rd dimension of `array2dcv`
    channel_nums            ::AbstractVector,
    dcv_well_idc_wfluo      ::AbstractVector,

    ## remove MySql dependency
    #
    ## arguments needed if `k` matrix needs to be computed
    ## `db_conn_default` is defined in "__init__.jl"
    # db_conn ::MySQL.MySQLHandle=db_conn_default,
    # calib_info ::Union{Integer,OrderedDict}=calib_info_AIR,
    # well_nums ::AbstractVector=[];

    calib_data              ::Associative,
    well_nums               ::AbstractVector =[];
    ## keyword arguments
    k4dcv_backup            ::K4Deconv =K4DCV,
    scaling_factor_dcv_vec  ::AbstractVector =SCALING_FACTOR_deconv_vec,
    out_format              ::Symbol = :both ## :array, :dict, :both
)
    log_debug("at deconvolute()")

    ## remove MySql dependency
    # k4dcv = (isa(calib_info, Integer) || begin
    #     step_ids = map(ci_value -> ci_value["step_id"], values(calib_info))
    #     length_step_ids = length(step_ids)
    #     length_step_ids <= 2 || length(unique(step_ids)) < length_step_ids
    # end) ? k4dcv_backup : get_k(db_conn, calib_info, well_nums) ## use default `well_proc` value
    const k4dcv = get_k(calib_data, well_nums)
    #
    const a2d_dim_unit, a2d_dim_well, a2d_dim_channel = size(ary2dcv)
    dcvd_ary3 = similar(ary2dcv)
    const k_inv_vs =
        map(1:a2d_dim_well) do w
            k4dcv.k_inv_vec[dcv_well_idc_wfluo[w]] .* scaling_factor_dcv_vec
        end
    for x in 1:a2d_dim_unit, w in 1:a2d_dim_well
        dcvd_ary3[x, w, :] = k_inv_vs[w] * ary2dcv[x, w, :] ## matrix * vector
    end
    #
    ## format output
    if (out_format == :array)
        dcvd = (dcvd_ary3,)
    else
        dcvd_dict = OrderedDict(map(1:a2d_dim_channel) do channel_i
            channel_nums[channel_i] => dcvd_ary3[:,:,channel_i]
        end) # do channel_i
        if (out_format == :dict)
            dcvd = (dcvd_dict,)
        elseif (out_format == :both)
            dcvd = (dcvd_ary3, dcvd_dict)
        else
            log_error("`out_format` must be :array, :dict or :both.")
        end
    end
    return (k4dcv, dcvd...)
end ## deconvolute()


## function: get cross-over constant matrix `k`
function get_k(
    ## remove MySql dependency
    # db_conn ::MySQL.MySQLHandle,

    ## info on experiment(s) used to calculate matrix K
    ## OrderedDict(
    ##    "water"=OrderedDict(calibration_id=..., step_id=...),
    ##    "channel_1"=OrderedDict(calibration_id=..., step_id=...),
    ##    "channel_2"=OrderedDict(calibration_id=...", step_id=...)
    # dcv_exp_info ::OrderedDict,

    ## possible  issue:
    ## step_ids are not provided together with calibration data
    ## I'm not sure that this is a problem because the calibration data
    ## in the request body is already specific to a single step.
    calib_data ::Associative,
    well_nums  ::AbstractVector =[];
    well_proc  ::Symbol = :vec, ## options: :mean, :vec.
    save_to    ::String ="" ## used: "k.jld"
)
    log_debug("at get_k()")

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
    # k4dcv_bydy = OrderedDict(map(cd_key_vec) do cd_key
    #    k_data_1dye, dcv_well_nums = dcv_data_dict[cd_key]
    #    return cd_key => k_data_1dye .- water_data
    # end)

    ## subtract water calibration data
    cd_key_vec = @p keys calib_data | collect | filter x -> (x != "water") ## `cd` - channel of dye.
    channel_nums = map(x -> Base.parse(split(x, "_")[2]), cd_key_vec)
    n_channels = length(channel_nums)
    water_data_2bt = reduce(hcat, calib_data["water"]["fluorescence_value"])
    #
    ## no information on well numbers in calibration info so make default assumptions
    n_wells = size(water_data_2bt, 1)
    water_well_nums = collect(1:n_wells)
    #
    ## vectorized
    # water_data = transpose(reduce(hcat,calib_data["water"]["fluorescence_value"]))
    # k4dcv_bydy = OrderedDict(map(channel_nums) do channel
    #     signal_data = transpose(reduce(hcat, calib_data[cd_key_vec[channel]]["fluorescence_value"]))
    #     return cd_key_vec[channel] => signal_data .- water_data
    # end)
    ## devectorized
    k4dcv_bydy = OrderedDict( ## `bydy` - by dye
        map(channel_nums) do c
            signal_data_2bt = reduce(hcat, calib_data[cd_key_vec[c]]["fluorescence_value"])
            k4dcv_c = Array{Float_T,2}(n_channels, n_wells)
            for i in 1:n_wells, j in channel_nums
                k4dcv_c[j,i] = signal_data_2bt[i,j] - water_data_2bt[i,j]
            end
            cd_key_vec[c] => k4dcv_c
        end)

    ## assuming `cd_key` (in the format of "channel_1", "channel_2", etc.)
    ## is the target channel of the dye, check whether the water-subtracted signal
    ## in the target channel is greater than that in the non-target channel(s)
    ## for each well and each dye.
    stop_msgs = Vector{String}()
    for target_channel_i in channel_nums
        signals = k4dcv_bydy[cd_key_vec[target_channel_i]]
        target_signals = signals[target_channel_i, :]
        for non_target_channel_i in channel_nums
            if (target_channel_i != non_target_channel_i)
                non_target_signals = signals[non_target_channel_i, :]
                failed_idc = find(target_signals .<= non_target_signals)
                if (length(failed_idc) > 0)
                    failed_well_nums_str = join(water_well_nums[failed_idc], ", ")
                    push!(stop_msgs, "Invalid deconvolution data for the dye targeting channel $target_channel_i: " *
                        "fluorescence value of non-target channel $non_target_channel_i is greater than or equal " *
                        "to that of target channel $target_channel_i in the following well(s) - $failed_well_nums_str")
                end
            end
        end ## for non_target_channel_i
    end ## for channel_i
    (length(stop_msgs) > 0) && log_error(join(stop_msgs, ""))

    inv_note_pt1 = ""
    inv_note_pt2 = "K matrix is singular, using `pinv` instead of `inv` to compute inverse matrix of K. " *
        "Deconvolution result may not be accurate. " *
        "This may be caused by using the same or a similar set of solutions in the steps for different dyes."

    if (well_proc == :mean) ## use average over channels, by well
        k_s =
            mapreduce( ## `cd` - channel of dye
                cd_key -> Array{Float_T}(sweep(sum)(/)(mean(k4dcv_bydy[cd_key], 2))),
                hcat,
                cd_key_vec)
        k_inv = try
            inv(k_s)
        catch err
            if isa(err, Base.LinAlg.SingularException)
                inv_note_pt1 = "Well mean"
                pinv(k_s)
            else
                throw(err)
            end ## if isa(err,
        end ## try
        k_inv_vec = fill(k_inv, n_wells)
        #
    elseif (well_proc == :vec)
        singular_well_nums = Vector{Int}()
        k_s = fill(ones(1,1), n_wells)
        k_inv_vec = similar(k_s)
        for i in 1:n_wells
            k_mtx =
                mapreduce(
                    cd_key -> Array{Float_T}(sweep(sum)(/)(k4dcv_bydy[cd_key][:, i])),
                    hcat,
                    cd_key_vec)
            k_s[i] = k_mtx
            ## k_inv_vec[i] = inv(k_mtx)
            k_inv_vec[i] = try
                inv(k_mtx)
            catch err
                if isa(err, Union{Base.LinAlg.SingularException, Base.LinAlg.LAPACKException})
                    push!(singular_well_nums, water_well_nums[i])
                    pinv(k_mtx)
                else
                    throw(err)
                end ## if isa(err
            end ## try
        end ## next well
        if (length(singular_well_nums) > 0)
            inv_note_pt1 = "Well(s) $(join(singular_well_nums, ", "))"
        end
    end ## if well_proc
    #
    inv_note = (length(inv_note_pt1) > 0) ? "$inv_note_pt1: $inv_note_pt2" : ""
    k4dcv = K4Deconv(k_s, k_inv_vec, inv_note)
    #
    (length(save_to) > 0) && save(save_to, "k4dcv", k4dcv)
    return k4dcv
end ## get_k()
