## deconv.jl
## color compensation / multi-channel deconvolution

import DataStructures.OrderedDict
import Memento: debug, error


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
    out_format              ::Symbol = :array ## :array, :dict, :both
)
    debug(logger, "at deconvolute()")

    ## remove MySql dependency
    # k4dcv = (isa(calib_info, Integer) || begin
    #     step_ids = map(ci_value -> ci_value["step_id"], values(calib_info))
    #     length_step_ids = length(step_ids)
    #     length_step_ids <= 2 || length(unique(step_ids)) < length_step_ids
    # end) ? k4dcv_backup : get_k(db_conn, calib_info, well_nums) ## use default `well_proc` value
    const k4dcv = get_k(calib_data, well_nums)
    const (a2d_dim_unit, a2d_dim_well, a2d_dim_channel) = size(ary2dcv)
    const k_inv_vs =
        map(range(1, a2d_dim_well)) do w
            k4dcv.k_inv_vec[dcv_well_idc_wfluo[w]] .* scaling_factor_dcv_vec
        end
    dcvd_ary3 = similar(ary2dcv)
    for x in range(1, a2d_dim_unit), w in range(1, a2d_dim_well)
        dcvd_ary3[x, w, :] = k_inv_vs[w] * ary2dcv[x, w, :] ## matrix * vector
    end
    dcvd_ary2dict() =
        OrderedDict(map(range(1, a2d_dim_channel)) do channel_i
            channel_nums[channel_i] => dcvd_ary3[:, :, channel_i]
        end) ## do channel_i

    ## format output
    const dcvd =
        if      (out_format == :array)  tuple(dcvd_ary3)
        elseif  (out_format == :dict)   tuple(dcvd_ary2dict())
        elseif  (out_format == :both)   tuple(dcvd_ary3, dcvd_ary2dict())
        else
            throw(ArgumentError("`out_format` must be :array, :dict or :both"))
        end ## if
    return (k4dcv, dcvd...)
end ## deconvolute()


## function: get cross-over constant matrix `k`
function get_k(
    ## remove MySql dependency
    # db_conn ::MySQL.MySQLHandle,

    ## info on experiment(s) used to calculate matrix K
    ## OrderedDict(
    ##    "water"    =OrderedDict(calibration_id=..., step_id=...),
    ##    "channel_1"=OrderedDict(calibration_id=..., step_id=...),
    ##    "channel_2"=OrderedDict(calibration_id=..., step_id=...))
    # dcv_exp_info ::OrderedDict,

    ## possible  issue:
    ## step_ids are not provided together with calibration data
    ## I'm not sure that this is a problem because the calibration data
    ## in the request body is already specific to a single step.
    calib_data ::Associative,
    well_nums  ::AbstractVector =[];
    ## keyword arguments
    well_proc  ::WellProc =well_proc_vec, ## options: well_proc_mean, well_proc_vec
    save_to    ::String ="" ## used: "k.jld"
)
    debug(logger, "at get_k()")

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
    const cd_key_vec = calib_data |> keys |> collect |> sift(!isequal(WATER_KEY)) ## `cd` - channel of dye.
    const channel_nums = map(x -> Base.parse(split(x, "_")[2]), cd_key_vec)
    const n_channels = length(channel_nums)
    const water_data_2bt = reduce(hcat, calib_data[WATER_KEY][FLUORESCENCE_VALUE_KEY])
    #
    ## no information on well numbers in calibration info so make default assumptions
    const n_wells = size(water_data_2bt, 1)
    const water_well_nums = collect(range(1, n_wells))
    #
    ## vectorized
    # water_data = transpose(reduce(hcat,calib_data[WATER_KEY][FLUORESCENCE_VALUE_KEY]))
    # k4dcv_bydy = OrderedDict(map(channel_nums) do channel
    #     signal_data = transpose(reduce(hcat, calib_data[cd_key_vec[channel]][FLUORESCENCE_VALUE_KEY]))
    #     return cd_key_vec[channel] => signal_data .- water_data
    # end)
    ## devectorized
    const k4dcv_bydy = OrderedDict( ## `bydy` - by dye
        map(channel_nums) do c
            const signal_data_2bt = reduce(hcat, calib_data[cd_key_vec[c]][FLUORESCENCE_VALUE_KEY])
            const k4dcv_c ::Array{Float_T,2} =
                [ signal_data_2bt[i,j] - water_data_2bt[i,j] for j in channel_nums, i in range(1, n_wells) ]
            cd_key_vec[c] => k4dcv_c
        end) ## do c
    #
    ## assuming `cd_key` (in the format of "channel_1", "channel_2", etc.)
    ## is the target channel of the dye, check whether the water-subtracted signal
    ## in the target channel is greater than that in the non-target channel(s)
    ## for each well and each dye.
    err_msgs = Vector{String}()
    for target_channel_i in channel_nums
        const target_signals = view(k4dcv_bydy[cd_key_vec[target_channel_i]], target_channel_i, :)
        for non_target_channel_i in channel_nums
            if (target_channel_i != non_target_channel_i)
                non_target_signals = view(k4dcv_bydy[cd_key_vec[target_channel_i]], non_target_channel_i, :)
                failed_idc = find(target_signals .<= non_target_signals)
                if (length(failed_idc) > 0)
                    push!(err_msgs,
                        "invalid deconvolution data for the dye targeting channel $target_channel_i: " *
                        "fluorescence value of non-target channel $non_target_channel_i " *
                        "is greater than or equal to that of target channel $target_channel_i " *
                        "in the following well(s) - " * join(water_well_nums[failed_idc], ", "))
                end ## if
            end ## if
        end ## for non_target_channel_i
    end ## for channel_i
    (length(err_msgs) > 0) && throw(DomainError(join(err_msgs, "; ")))

    ## compute inverses and return
    const (k_s, k_inv_vec, inv_note) = calc_kinv(Val{well_proc}(), k4dcv_bydy, cd_key_vec, n_wells)
    const k4dcv = K4Deconv(k_s, k_inv_vec, (length(inv_note) > 0 ? inv_note * INV_NOTE_PT2 : ""))
    (length(save_to) > 0) && save(save_to, "k4dcv", k4dcv)
    return k4dcv
end ## get_k()


## dependencies of get_k()

function calc_kinv(
    ::Val{well_proc_mean},
    k4dcv_bydy ::Associative,
    cd_key_vec ::AbstractVector,
    n_wells    ::Integer
)
    inv_note = false
    const k_s =
        mapreduce( ## `cd` - channel of dye
            cd_key -> Array{Float_T}(sweep(sum)(/)(mean(k4dcv_bydy[cd_key], 2))),
            hcat,
            cd_key_vec)
    const k_inv = try
        inv(k_s)
    catch err
        if isa(err, Base.LinAlg.SingularException)
            inv_note = true
            pinv(k_s)
        else
            rethrow(err)
        end ## if isa(err,
    end ## try
    return k_s, fill(k_inv, n_wells), inv_note ? "" : "Well mean"
end

function calc_kinv(
    ::Val{well_proc_vec},
    k4dcv_bydy ::Associative,
    cd_key_vec ::AbstractVector,
    n_wells    ::Integer
)
    singular_well_nums = Vector{Int}()
    const k_s =
        [   mapreduce(
                cd_key -> Array{Float_T}(sweep(sum)(/)(k4dcv_bydy[cd_key][:, i])),
                hcat,
                cd_key_vec)
            for i in range(1, n_wells) ]
    const k_inv_vec =
        [   try
                inv(k_s[i])
            catch err
                if isa(err, Union{Base.LinAlg.SingularException, Base.LinAlg.LAPACKException})
                    push!(singular_well_nums, water_well_nums[i])
                    pinv(k_s[i])
                else
                    rethrow(err)
                end ## if isa(err
            end ## try
            for i in range(1, n_wells) ]
    const inv_note = (length(singular_well_nums) > 0) ?
        "Well(s) " * string(join(singular_well_nums, ", ")) : ""
    return k_s, k_inv_vec, inv_note
end


#
