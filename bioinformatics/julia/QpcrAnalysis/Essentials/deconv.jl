# color compensation / multi-channel deconvolution


# multi-channel deconvolution
function deconv(
    ary2dcv::AbstractArray, # dim1 is unit, which can be cycle (amplification), temperature point (melting curve), or step type (like "water", "channel_1", "channel_2" for calibration experiment); dim2 must be well, dim3 must be channel
    channels::AbstractVector, # must be the same length as 3rd dimension of `array2dcv`
    dcv_well_idc_wfluo::AbstractVector,

    # arguments needed k matrix needs to be computed
    db_conn::MySQL.MySQLHandle=db_conn_default, # `db_conn_default` is defined in "__init__.jl"
    calib_info::Union{Integer,OrderedDict}=calib_info_AIR,
    well_nums::AbstractVector=[];

    out_format::AbstractString="both" # "array", "dict", "both"
    )

    a2d_dim1, a2d_dim_well, a2d_dim_channel = size(ary2dcv)

    scaling_factor_dcv_vec = map(channels) do channel
        SCALING_FACTORS_deconv[channel]
    end

    dcvd_ary3 = similar(ary2dcv)

    k_dict = (isa(calib_info, Integer) || begin
        step_ids = map(ci_value -> ci_value["step_id"], values(calib_info))
        length_step_ids = length(step_ids)
        length_step_ids <= 2 || length(unique(step_ids)) < length_step_ids
    end) ? K_DICT : get_k(db_conn, calib_info, well_nums) # use default `well_proc` value

    k_inv_vec = k_dict["k_inv_vec"]

    for i1 in 1:a2d_dim1, i_well in 1:a2d_dim_well
        dcvd_ary3[i1, i_well, :] = *(
            k_inv_vec[dcv_well_idc_wfluo[i_well]],
            reshape(ary2dcv[i1, i_well, :], a2d_dim_channel)
        ) .* scaling_factor_dcv_vec
    end

    if out_format == "array"
        dcvd = (dcvd_ary3,)
    else
        dcvd_dict = OrderedDict(map(1:a2d_dim_channel) do channel_i
            channels[channel_i] => dcvd_ary3[:,:,channel_i]
        end) # do channel
        if out_format == "dict"
            dcvd = (dcvd_dict,)
        elseif out_format == "both"
            dcvd = (dcvd_ary3, dcvd_dict)
        else
            error("`out_format` must be \"array\", \"dict\" or \"both\".")
        end # if out_format == "dict"
    end # if out_format == "array"

    return (k_dict, dcvd...)

end # deconv


# function: get cross-over constant matrix k
function get_k(
    db_conn::MySQL.MySQLHandle, # MySQL database connection
    dcv_exp_info::OrderedDict, # OrderedDict("water"=OrderedDict(calibration_id=..., step_id=...), "channel_1"=OrderedDict(calibration_id=..., step_id=...),  "channel_2"=OrderedDict(calibration_id=...", step_id=...). # info on experiment(s) used to calculate matrix k
    well_nums::AbstractVector=[];
    well_proc::AbstractString="vec", # options: "mean", "vec".
    Float_T::DataType=Float32, # ensure compatibility with other OSs
    save_to::AbstractString="" # used: "k.jld"
    )

    dcv_exp_info = ensure_ci(db_conn, dcv_exp_info)

    calib_key_vec = get_ordered_keys(dcv_exp_info)
    cd_key_vec = calib_key_vec[2:end] # cd = channel of dye. "water" is index 1 per original order.

    dcv_data_dict = get_full_calib_data(db_conn, dcv_exp_info, well_nums)

    water_data, water_well_nums = dcv_data_dict["water"]
    num_wells = length(water_well_nums)

    k_dict_bydy = OrderedDict(map(cd_key_vec) do cd_key
        k_data_1dye, dcv_well_nums = dcv_data_dict[cd_key]
        return (cd_key, k_data_1dye .- water_data)
    end) # `dcv_well_nums` is not passed on because expected to be the same as `water_well_nums`, otherwise error will be raised by `get_full_calib_data`

    inv_note_pt1 = ""
    inv_note_pt2 = "K matrix is singular, using `pinv` instead of `inv` to compute inverse matrix of K. Deconvolution result may not be accurate. This may be caused by using the same or a similar set of solutions in the steps for different dyes. "

    if well_proc == "mean"
        k_s = hcat(
            map(cd_key_vec) do cd_key
                k_mean_vec_1dye = mean(k_dict_bydy[cd_key], 2)
                k_1dye = k_mean_vec_1dye / sum(k_mean_vec_1dye)
                return Array{Float_T}(k_1dye)
            end...) # do cd_key
        k_inv = try inv(k_s)
        catch err
            if isa(err, Base.LinAlg.SingularException)
                inv_note_pt1 = "Well mean"
                pinv(k_s)
            end # if isa(err,
        end # try
        k_inv_vec = fill(k_inv, num_wells)

    elseif well_proc == "vec"
        singular_well_nums = Vector{Int}()
        k_s = fill(ones(1,1), num_wells)
        k_inv_vec = similar(k_s)
        for i in 1:num_wells
            k_mtx = hcat(map(cd_key_vec) do cd_key
                k_vec_1dye = k_dict_bydy[cd_key][:,i]
                k_1dye = k_vec_1dye / sum(k_vec_1dye)
                return Array{Float_T}(k_1dye)
            end...) # do cd_key
            k_s[i] = k_mtx
            # k_inv_vec[i] = inv(k_mtx)
            k_inv_vec[i] = try inv(k_mtx)
            catch err
                if isa(err, Union{Base.LinAlg.SingularException, Base.LinAlg.LAPACKException})
                    push!(singular_well_nums, water_well_nums[i])
                    pinv(k_mtx)
                else
                    throw(err)
                end # if isa(err
            end # try
        end # for
        if length(singular_well_nums) > 0
            inv_note_pt1 = "Well(s) $(join(singular_well_nums, ", "))"
        end # if length

    end # if well_proc

    inv_note = length(inv_note_pt1) > 0 ? "$inv_note_pt1: $inv_note_pt2" : ""

    if length(save_to) > 0
        save(save_to,
            "k_s", k_s,
            "k_inv_vec", k_inv_vec,
            "inv_note", inv_note
        )
    end

    return OrderedDict(
        "k_s"=>k_s,
        "k_inv_vec"=>k_inv_vec,
        "inv_note"=>inv_note
    )

end # get_k
