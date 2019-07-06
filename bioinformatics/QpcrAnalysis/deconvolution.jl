## deconv.jl
## color compensation / multi-channel deconvolution

import DataStructures.OrderedDict
import Memento: debug, error


## default values
const DEFAULT_DCV_BACKUP_K      = K4DCV
const DEFAULT_DCV_WELL_PROC     = well_proc_vec

## preset values
const DECONVOLUTION_SCALING_FACTOR = [1.0, 4.2]    ## used: [1, oneof(1, 2, 3.5, 8, 7, 5.6, 4.2)]


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

    calibration_data        ::CalibrationData{<: Real},
    well_nums               ::AbstractVector;
    ## keyword arguments
    k4dcv_backup            ::K4Deconv = DEFAULT_DCV_BACKUP_K, ## argument not used
    scaling_factor_dcv_vec  ::AbstractVector = DECONVOLUTION_SCALING_FACTOR,
    out_format              ::Symbol = :array ## :array, :dict, :both
)
    debug(logger, "at deconvolute()")

    ## remove MySql dependency
    # k4dcv = (isa(calib_info, Integer) || begin
    #     step_ids = map(ci_value -> ci_value["step_id"], values(calib_info))
    #     length_step_ids = length(step_ids)
    #     length_step_ids <= 2 || length(unique(step_ids)) < length_step_ids
    # end) ? k4dcv_backup : get_k(db_conn, calib_info, well_nums) ## use default `well_proc` value
    const k4dcv = get_k(calibration_data, well_nums)
    const (a2d_dim_unit, a2d_dim_well, a2d_dim_channel) = size(ary2dcv)
    const k_inv_vs =
        map(range(1, a2d_dim_well)) do w
            k4dcv.k_inv_vec[dcv_well_idc_wfluo[w]] .* scaling_factor_dcv_vec
        end
    deconvoluted_array = similar(ary2dcv)
    for x in range(1, a2d_dim_unit), w in range(1, a2d_dim_well)
        deconvoluted_array[x, w, :] = k_inv_vs[w] * ary2dcv[x, w, :] ## matrix * vector
    end
    deconvoluted_dict() =
        OrderedDict(map(range(1, a2d_dim_channel)) do channel_i
            channel_nums[channel_i] => deconvoluted_array[:, :, channel_i]
        end) ## do channel_i
    ## format output
    const deconvoluted_data =
        if      (out_format == :array)  tuple(deconvoluted_array)
        elseif  (out_format == :dict)   tuple(deconvoluted_dict())
        elseif  (out_format == :both)   tuple(deconvoluted_array, deconvoluted_dict())
        else
            throw(ArgumentError("`out_format` must be :array, :dict or :both"))
        end ## if
    return (k4dcv, deconvoluted_data...)
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
    calibration_data    ::CalibrationData{<: Real},
    well_nums           ::AbstractVector;
    ## keyword arguments
    well_proc           ::WellProc = DEFAULT_DCV_WELL_PROC, ## options: well_proc_mean, well_proc_vec
    save_to             ::String ="" ## used: "k.jld"
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
    # k4dcv_bydye = OrderedDict(map(cd_key_vec) do cd_key
    #    k_data_1dye, dcv_well_nums = dcv_data_dict[cd_key]
    #    return cd_key => k_data_1dye .- water_data
    # end)
    ## subtract water calibration data
    const channel_nums = CHANNELS[1:calibration_data.num_channels]
    const dyes = [Symbol(CHANNEL_KEY * "_" * string(c)) for c in channel_nums]
    const water_data_2bt = reduce(hcat, calibration_data.water)
    #
    ## no information on well numbers in calibration info so make default assumptions
    const n_wells = size(water_data_2bt, 1)
    const water_well_nums = collect(1:n_wells)
    #
    ## vectorized
    # water_data = transpose(reduce(hcat,calib_data[WATER_KEY][FLUORESCENCE_VALUE_KEY]))
    # k4dcv_bydye = OrderedDict(map(channel_nums) do channel
    #     signal_data = transpose(reduce(hcat, calib_data[dyes[channel]][FLUORESCENCE_VALUE_KEY]))
    #     return dyes[channel] => signal_data .- water_data
    # end)
    ## devectorized
    const k4dcv_bydye = OrderedDict(
        map(channel_nums) do c
            const signal_data_2bt = reduce(hcat, getfield(calibration_data, dyes[c]))
            const k4dcv_c ::Array{Float_T,2} =
                [   signal_data_2bt[i,j] - water_data_2bt[i,j]
                    for j in channel_nums, i in 1:n_wells       ]
            dyes[c] => k4dcv_c
        end) ## do c
    #
    ## check that the water-subtracted signal in the target channel
    ## is greater than that in the non-target channel(s) for each well and each dye
    err_msgs = Vector{String}()
    for target_channel_i in channel_nums
        const target_signals = view(k4dcv_bydye[dyes[target_channel_i]], target_channel_i, :)
        for non_target_channel_i in channel_nums
            if (target_channel_i != non_target_channel_i)
                non_target_signals = view(k4dcv_bydye[dyes[target_channel_i]], non_target_channel_i, :)
                failed_idc = find(target_signals .<= non_target_signals)
                if length(failed_idc) > 0
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
    const INV_NOTE_PT2 = ": K matrix is singular, using `pinv` instead of `inv` " *
    "to compute inverse matrix of K. Deconvolution result may not be accurate. " *
    "This may be caused by using the same or a similar set of solutions " *
    "in the steps for different dyes."
    const (k_s, k_inv_vec, inv_note) =
        calc_kinv(Val{well_proc}, k4dcv_bydye, dyes, n_wells, water_well_nums)
    const k4dcv = K4Deconv(k_s, k_inv_vec, (length(inv_note) > 0 ? inv_note * INV_NOTE_PT2 : ""))
    (length(save_to) > 0) && save(save_to, "k4dcv", k4dcv)
    return k4dcv
end ## get_k()


## dependencies of get_k() >>

function calc_kinv(
    ::Type{Val{well_proc_mean}},
    k4dcv_bydye     ::Associative,
    dyes            ::AbstractVector,
    n_wells         ::Integer,
    water_well_nums ::AbstractVector
)
    inv_note = false
    const k_s =
        mapreduce( ## `cd` - channel of dye
            cd_key -> Array{Float_T}(sweep(sum)(/)(mean(k4dcv_bydye[cd_key], 2))),
            hcat,
            dyes)
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
    ::Type{Val{well_proc_vec}},
    k4dcv_bydye     ::Associative,
    dyes            ::AbstractVector,
    n_wells         ::Integer,
    water_well_nums ::AbstractVector
)
    singular_well_nums = Vector{Int}()
    const k_s =
        [   mapreduce(
                cd_key -> Array{Float_T}(sweep(sum)(/)(k4dcv_bydye[cd_key][:, i])),
                hcat,
                dyes)
            for i in 1:n_wells   ]
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
            for i in 1:n_wells   ]
    const inv_note = (length(singular_well_nums) > 0) ?
        "Well(s) " * string(join(singular_well_nums, ", ")) : ""
    return k_s, k_inv_vec, inv_note
end
