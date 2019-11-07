#===========================================================m====================
    calibration.jl

    calibration procedure:
    1. multichannel deconvolution
    2. normalize variation between wells in absolute fluorescence

===============================================================================#

import DataStructures.OrderedDict
import StaticArrays: MArray, SArray, SMatrix, SVector
import Memento: debug, error



#===============================================================================
    constants >>
===============================================================================#

## default values
const DEFAULT_CAL_FIRST_WELL        = 1

## preset values
const NORMALIZATION_SCALING_FACTOR  = 3.7           ## used: 9e5, 1e5, 1.2e6, 3.0
const DECONVOLUTION_SCALING_FACTOR  = [1.0, 4.2]    ## used: [1, oneof(1, 2, 3.5, 8, 7, 5.6, 4.2)]
const DECONVOLUTION_BACKUP_K        = K4DCV         ## not used

## convenience array indices
const WATER  = 1
const SIGNAL = 2


#===============================================================================
    function definitions >>
===============================================================================#

"Perform deconvolution between channels and normalize variation between wells."
function calibrate(
    i                       ::Input,
    calibration_data        ::CalibrationData{<: NumberOfChannels, <: Union{Int_T,Float_T}},
    calibration_args        ::CalibrationParameters,
    raw                     ::RawData{<: Union{Int_T,Float_T}},         ## 3D array of raw fluorescence
    data_format             ::DataFormat,               ## array, dict, both
)
    debug(logger, "at calibrate()")

    ## remove MySql dependency
    # calib_info = ensure_ci(db_conn, calib_info)
    # norm_data, norm_well_nums = prep_normalize(db_conn,
    #     calib_info, well_nums_in_req, dye_in, dyes_to_fill)

    ## prepare data for normalization
    (norm_data, norm_wells) = prep_normalize(calibration_data)

    # if length(well_nums_found_in_req) == 0
    #     well_nums_found_in_req = norm_wells
    # end

    ## remove MySql dependency
    #
    # matched_well_idc = find(norm_well_nums) do norm_well_num
    #     norm_well_num in well_nums_found_in_raw
    # end ## do norm_well_num

    ## match (explicit) well numbers in the experimental data
    ## with (presumed complete) set of well numbers in calibration data
    matched_wells = indexin(i.wells, norm_wells)
    matched_exp_well_idc = find(matched_wells)
    matched_calib_well_idc = SVector{length(matched_exp_well_idc)}(
        matched_wells[matched_exp_well_idc])

    #
    ## subtract background
    background_subtracted_data =
        subtract_background(
            raw.data,
            norm_data[:,:,WATER],
            matched_wells,
            matched_exp_well_idc)

    #
    (k_deconv, deconvoluted_data) =
        if  calibration_args.dcv &&
            isa(calibration_data, CalibrationData{DualChannel,<: Union{Int_T,Float_T}})
            ## addition with flexible ratio instead of deconvolution (commented out)
            # k_inv_vec = fill(reshape(DataArray([1, 0, 1, 0]), 2, 2), 16)

            ## removing MySql dependency
            # k4dcv, deconvoluted_data = deconvolute(
            #     1. * background_subtracted_data,
            #     channel_nums, matched_well_idc,
            #     db_conn, calib_info, well_nums_in_req;
            #     out_format="array")
            deconvolute(
                calibration_data,
                calibration_args,
                background_subtracted_data |> cast(bless(Float_T)),
                matched_calib_well_idc,
                norm_wells[matched_calib_well_idc],
                DECONVOLUTION_BACKUP_K,
                DECONVOLUTION_SCALING_FACTOR,
                array)
        else ## !dcv
            DeconvolutionMatrices(calibration_data, calibration_args),
                background_subtracted_data
        end
    #
    calibrated_array =
        map(1:i.num_channels) do channel
            perform_normalize(
                deconvoluted_data[:, :, channel],
                norm_data,
                matched_exp_well_idc,
                matched_calib_well_idc,
                channel,
                calibration_args.subtract_water,
                NORMALIZATION_SCALING_FACTOR)
        end #= do channel =# |>
        splat(tie(3)) ## not gather(tie(3)) because we need 3 dimensions for single channel data
    #
    ## format output
    ## the following line of code needs the keys of calibrated_dict to be in sort order
    calibrated_dict()  =
        OrderedDict(
            map(1:i.num_channels) do channel
                channel => calibrated_array[:, :, channel]
            end)
    calibrated_data =
        if      (data_format == array)  tuple(calibrated_array)
        elseif  (data_format == dict)   tuple(calibrated_dict())
        elseif  (data_format == both)   tuple(calibrated_array, calibrated_dict())
        else                            throw(ArgumentException(
                                            "`data_format` must be array, dict or both"))
        end ## if
    return (
        background_subtracted_data,
        k_deconv,
        deconvoluted_data,
        norm_data,
        norm_wells,
        calibrated_data...)
end ## calibrate()


## called by calibrate()
function subtract_background(
    raw_data                ::Array{<: Union{Int_T,Float_T}, 3},
    water_data              ::SArray{S,<: Union{Int_T,Float_T},2} where {S},
    matched_wells           ::Array{Int_T},
    matched_exp_wells_idc   ::Array{Int_T},
)
    ## vectorized
    # raw_data[:,matched_exp_wells_idc,:] .-
    #     permutedims(cat(3,water_data[matched_wells[matched_exp_wells_idc],:]),[3,1,2])
    ## devectorized
    [   raw_data[ui, wi, ci] - water_data[matched_wells[wi], ci]
        for ui in 1:size(raw_data, 1),
            wi in matched_exp_wells_idc,
            ci in 1:size(raw_data, 3)   ]
end


#==============================================================================#


"Check validity of optical calibration data."
function prep_normalize(calibration_data ::CalibrationData{DualChannel, <: Union{Int_T,Float_T}})
    debug(logger, "at prep_normalize()")
    norm_data = get_norm_data(calibration_data)
    ## index wells in calibration data starting at `DEFAULT_CAL_FIRST_WELL` = 0
    ## issue:
    ## using the current format for the request body there is no well_num information
    ## associated with the calibration data
    num_wells = size(calibration_data.array, 1)
    num_channels = 2
    signal_wells = num_wells |> from(DEFAULT_CAL_FIRST_WELL) |>
        mold(Symbol) |> SVector{num_wells}
    ## check whether signal fluorescence > water fluorescence
    failed = norm_data[:, :, SIGNAL] .<= norm_data[:, :, WATER]
    if any(failed)
        err_msgs = Vector{String}()
        for channel in 1:num_channels
            invalid = find(failed[:, channel])
            if length(invalid) > 0
                failed_wells = join(signal_wells[invalid], ", ")
                push!(err_msgs, "invalid calibration data in channel $channel: " *
                    "fluorescence value of water is greater than or equal to that of dye " *
                    "in the following well(s) - " * failed_wells)
            end ## if invalid
        end ## next channel
        throw(ArgumentError(join(err_msgs, "; ")))
    end ## if any(failed)

    ## issue:
    ## this feature has been temporarily disabled while
    ## removing MySql dependency in get_wva_data because
    ## using the current format for the request body
    ## we cannot subset the calibration data by step_id
    # if length(dyes_to_fill) > 0 ## extrapolate well-to-well variation data for missing channels
    #     println("Preset well-to-well variation data is used to extrapolate " *
    #         "calibration data for missing channels.")
    #     channels_missing = setdiff(channels_in_water, channels_in_signal)
    #     dyes_dyes_to_fill_channels =
    #         map(dye -> DYE2CHST[dye]["channel"], dyes_to_fill) ## DYE2CHST is defined in module scope
    #     check_subset(
    #         Ccsc(channels_missing, "Channels missing well-to-well variation data"),
    #         Ccsc(dyes_dyes_to_fill_channels, "channels corresponding to the dyes " *
    #             "of which well-to-well variation data is needed")
    #     )
    #     # process preset calibration data
    #     preset_step_ids = OrderedDict([
    #         dye => DYE2CHST[dye]["step_id"]
    #         for dye in keys(DYE2CHST)
    #     ])
    #     preset_signal_data_dict, dyes_in_preset =
    #         get_wva_data(PRESET_calib_ids["signal"], preset_step_ids, db_conn, "dye") ## `well_nums` is not passed on
    #     pivot_preset = preset_signal_data_dict[dye_in]
    #     pivot_in = signal_data_dict[DYE2CHST[dye_in]["channel"]]
    #     in2preset = pivot_in ./ pivot_preset
    #     for dye in dyes_to_fill
    #         signal_data_dict[DYE2CHST[dye]["channel"]] = preset_signal_data_dict[dye] .* in2preset
    #     end
    # end ## if

    return (norm_data, signal_wells)
end ## prep_normalize()


function prep_normalize(calibration_data ::CalibrationData{SingleChannel, <: Union{Int_T,Float_T}})
    debug(logger, "at prep_normalize()")
    norm_data = calibration_data.array
    num_wells = size(calibration_data.array, 1)
    signal_wells = num_wells |> from(DEFAULT_CAL_FIRST_WELL) |>
        mold(Symbol) |> SVector{num_wells}
    ## check whether signal fluorescence > water fluorescence
    failed = norm_data[:, 1, SIGNAL] .<= norm_data[:, 1, WATER]
    if any(failed)
        err_msg = "invalid calibration data in channel 1: " *
            "fluorescence value of water is greater than or equal to that of dye " *
            "in the following well(s) - " * join(signal_wells[find(failed)], ", ")
        throw(ArgumentError(err_msg))
    end ## if any(failed)
    return (norm_data, signal_wells)
end ## prep_normalize()


## called by prep_normalize() >>

get_norm_data(data ::CalibrationData{SingleChannel, <: Union{Int_T,Float_T}}) =
    data.array

function get_norm_data(data ::CalibrationData{DualChannel,R}) where {R <: Union{Int_T,Float_T}}
    local (water, dye1, dye2) = 1:3
    SArray{Tuple{size(data.array,1),2,2},R}( ## hcat converts from SArray to Array
        hcat(
            data.array[:, SVector{1}(1), SVector{2}(water, dye1)],    ## channel 1
            data.array[:, SVector{1}(2), SVector{2}(water, dye2)]))   ## channel 2
end


#==============================================================================#

#=
    perform_normalize(): each dye only has data for its target channel;
    calibration/calib/oc - used for `deconvolute` and `normalize`,
    each dye has data for both target and non-target channels.
    Input `fluo` and output: dim2 indexed by well and dim1 indexed by unit,
    which can be cycle (amplification) or temperature point (melt curve).
    Output does not include the automatically created column at index 1
    from rownames of input array as R does
=#

## called from calibrate()
"Normalize variation between wells in absolute fluorescence values."
function perform_normalize(
    fluorescence                    ::Array{<: Union{Int_T,Float_T},2},
    norm_data                       ::SArray{S,<: Union{Int_T,Float_T},3} where {S},
    matched_exp_well_idc            ::Array{Int_T},
    matched_calib_well_idc          ::SVector{L,Int_T} where {L},
    channel                         ::Int_T,
    subtract_water                  ::Bool,
    normalization_scaling_factor    ::Float_T,
)
    debug(logger, "at perform_normalize()")
    #
    ## devectorized code avoids transposing data matrix
    if subtract_water == false
        smw = norm_data[matched_calib_well_idc, channel, SIGNAL]
        return ([
            normalization_scaling_factor * mean(smw) *
                fluorescence[u, matched_exp_well_idc[wi]] / smw[wi]
                    for u  in 1:size(fluorescence, 1),
                        wi in eachindex(matched_exp_well_idc)])
    end
    #
    ## subtract_water == true
    norm_water = norm_data[matched_calib_well_idc, channel, WATER]
    smw = norm_data[matched_calib_well_idc, channel, SIGNAL] .- norm_water
    return ([
        normalization_scaling_factor * mean(smw) *
            (fluorescence[u, matched_exp_well_idc[wi]] - norm_water[wi]) / smw[wi]
                for u  in 1:size(fluorescence, 1),
                    wi in eachindex(matched_exp_well_idc)])
end ## perform_normalize


#==============================================================================#


## called from calibrate()
"Perform multi-channel deconvolution of fluorescence values."
function deconvolute(
    ## ary2dcv dim1 is unit, which can be cycle (amplification), temperature point (melting curve),
    ## or step type (like "water", "channel_1", "channel_2" for calibration experiment);
    ## ary2dcv dim2 must be well, ary2dcv dim3 must be channel
    calibration_data        ::CalibrationData{DualChannel, <: Union{Int_T,Float_T}},
    calibration_args        ::CalibrationParameters,
    ary2dcv                 ::Array{Float_T,3},
    matched_calib_well_idc  ::SVector{L,Int_T} where {L},
    wells                   ::SVector{L,Symbol} where {L},
    k_deconv_backup         ::DeconvolutionMatrices, ## argument not used
    scaling_factor_dcv_vec  ::Vector{Float_T},
    data_format             ::DataFormat, ## array, dict, both

    ## remove MySql dependency
    #
    ## arguments needed if `k` matrix needs to be computed
    ## `db_conn_default` is defined in "__init__.jl"
    # db_conn ::MySQL.MySQLHandle=db_conn_default,
    # calib_info ::Union{Integer,OrderedDict}=calib_info_AIR,
    # well_nums ::AbstractVector=[];
)
    debug(logger, "at deconvolute()")

    ## remove MySql dependency
    # k_deconv = (isa(calib_info, Integer) || begin
    #     step_ids = map(ci_value -> ci_value["step_id"], values(calib_info))
    #     length_step_ids = length(step_ids)
    #     length_step_ids <= 2 || length(unique(step_ids)) < length_step_ids
    # end) ? k_deconv_backup : get_k(db_conn, calib_info, well_nums) ## use default `well_proc` value

    k_deconv = get_k(
        calibration_data,
        calibration_args,
        matched_calib_well_idc,
        wells)
    (num_units, num_channels) = size(ary2dcv,1,3)
    scaled_k_inv_vecs =
        map(eachindex(matched_calib_well_idc)) do wi
            k_deconv.k_inv_vec[wi] .* scaling_factor_dcv_vec
        end
    deconvoluted_array = similar(ary2dcv)
    for ui in 1:num_units, wi in eachindex(matched_calib_well_idc)
        deconvoluted_array[ui, wi, :] =
            scaled_k_inv_vecs[wi] * ary2dcv[ui, wi, :] ## matrix * vector
    end
    deconvoluted_dict() =
        OrderedDict(
            channel => deconvoluted_array[:, :, channel]
            for channel in 1:num_channels)
    ## format output
    deconvoluted_data =
        if      (data_format == array)  tuple(deconvoluted_array)
        elseif  (data_format == dict)   tuple(deconvoluted_dict())
        elseif  (data_format == both)   tuple(deconvoluted_array, deconvoluted_dict())
        else
            throw(ArgumentError("`out_format` must be array, dict or both"))
        end ## if
    return (k_deconv, deconvoluted_data...)
end ## deconvolute()


deconvolute(
    calibration_data        ::CalibrationData{SingleChannel, <: Union{Int_T,Float_T}},
    calibration_args        ::CalibrationParameters,
    ary2dcv                 ::Array{Float_T,3},
    matched_calib_well_idc  ::SVector{L,Int_T} where {L},
    wells                   ::SVector{L,Symbol} where {L},
    k_deconv_backup         ::DeconvolutionMatrices, ## argument not used
    scaling_factor_dcv_vec  ::Vector{Float_T},
    data_format             ::DataFormat, ## array, dict, both
) =
    throw(ArgumentError("cannot perform multi-channel deconvolution " *
        "using single channel calibration data"))


#==============================================================================#


"Calculate the matrix `k` that describes crosstalk between channels."
function get_k(
    calibration_data        ::CalibrationData{DualChannel, <: Union{Int_T,Float_T}},
    calibration_args        ::CalibrationParameters,
    matched_calib_well_idc  ::SVector{L,Int_T} where {L},
    wells                   ::SVector{L,Symbol} where {L};
    save_to                 ::String = "" ## used: "k.jld"

    ## remove MySql dependency
    #
    # db_conn ::MySQL.MySQLHandle,
    ## info on experiment(s) used to calculate matrix K
    ## OrderedDict(
    ##    "water"    =OrderedDict(calibration_id=..., step_id=...),
    ##    "channel_1"=OrderedDict(calibration_id=..., step_id=...),
    ##    "channel_2"=OrderedDict(calibration_id=..., step_id=...))
    # dcv_exp_info ::OrderedDict,
    #
    ## possible  issue:
    ## originally step_ids were provided together with calibration data
    ## I'm not sure that this is a problem now because the calibration data
    ## in the request body is already specific to a single step.
)
    debug(logger, "at get_k()")

    ## remove MySql dependency
    #
    # dcv_exp_info = ensure_ci(db_conn, dcv_exp_info)
    #
    # calib_key_vec = get_ordered_keys(dcv_exp_info)
    # cd_key_vec = calib_key_vec[2:end] # cd = channel of dye, "water" is index 1
    #
    # dcv_data_dict = get_full_calib_data(db_conn, dcv_exp_info, well_nums)
    #
    # water_data, water_well_nums = dcv_data_dict["water"]
    # num_wells = length(water_well_nums)
    #
    ## `dcv_well_nums` is not passed on because it is
    ## expected to be the same as `water_well_nums`,
    ## otherwise error will be raised by `get_full_calib_data`
    # smw_bydye = OrderedDict(map(cd_key_vec) do cd_key
    #    k_data_1dye, dcv_well_nums = dcv_data_dict[cd_key]
    #    return cd_key => k_data_1dye .- water_data
    # end)

    ## water-subtracted calibration data
    smw = SArray{Tuple{2,2,length(matched_calib_well_idc)},Float_T}([
        calibration_data.array[well, channel, dye] - calibration_data.array[well, channel, WATER]
        for channel in 1:2,
            dye     in 2:3,
            well    in matched_calib_well_idc])
    # const smw2 = SArray{Tuple{2,2,length(matched_calib_well_idc)},Float_T}(
    #
    ## check that the water-subtracted signal in the target channel
    ## is greater than that in the non-target channel(s) for each well and each dye
    failed =
        map(DYES) do dye
            target     = dye
            non_target = 3 - target
            smw[target, dye, :] .<= smw[non_target, dye, :]
        end #= next channel =# |>
        gather(hcat)
    if any(failed)
        err_msgs = Vector{String}()
        for dye in DYES
            invalid = find(failed[:, dye])
            if length(invalid) > 0
                target     = dye
                non_target = 3 - target
                wells_invalid = join(wells[invalid], ", ")
                push!(err_msgs,
                    "invalid deconvolution data for the dye targeting channel $target: " *
                    "fluorescence value of non-target channel $non_target " *
                    "is greater than or equal to that of target channel $target " *
                    "in the following well(s) - $wells_invalid")
            end ## if
        end ## next dye
        throw(ArgumentError(join(err_msgs, "; ")))
    end ## if any(failed)
    #
    ## compute inverses and return
    INV_NOTE_PT2 = ": K matrix is singular, using `pinv` instead of `inv` " *
    "to compute inverse matrix of K. Deconvolution result may not be accurate. " *
    "This may be caused by using the same or a similar set of solutions " *
    "in the steps for different dyes."
    (k_s, k_inv_vec, inv_note) =
        calc_kinv(Val{calibration_args.k_method}, smw, DYES, wells)
    k_deconv =
        DeconvolutionMatrices(
            k_s,
            k_inv_vec,
            (length(inv_note) > 0 ? inv_note * INV_NOTE_PT2 : ""))
    (length(save_to) > 0) && save(save_to, "k_deconv", k_deconv)
    return k_deconv
end ## get_k()


get_k(
    calibration_data        ::CalibrationData{SingleChannel, <: Union{Int_T,Float_T}},
    calibration_args        ::CalibrationParameters,
    matched_calib_well_idc  ::SVector{L,Int_T} where {L},
    wells                   ::SVector{L,Symbol} where {L};
    save_to                 ::String = "" ## used: "k.jld"
) =
    throw(ArgumentError("cannot calculate deconvolution matrices " *
        "using single channel calibration data"))


#==============================================================================#


## functions called by get_k() >>

"Calculate a single deconvolution matrix K, averaging across all wells"
function calc_kinv(
    ::Type{Val{well_proc_mean}},
    smw             ::SArray{S,<: Float_T,3} where {S},
    dyes            ::SVector{L,Int_T},
    wells           ::SVector{L,Symbol}
) where {L}
    inv_note = false
    k_s =
        map(eachindex(dyes)) do dye
            SVector{L,Float_T}(sweep(sum)(/)(mean(smw[:,dye,:], 2)))
        end #= next dye =# |>
        gather(hcat)
    k_inv = try
        inv(k_s)
    catch err
        if isa(err, Base.LinAlg.SingularException)
            inv_note = true
            pinv(k_s)
        else
            rethrow(err)
        end ## if isa(err,
    end ## try
    return
        [k_s],
        fill(k_inv, length(wells)),
        inv_note ? "" : "Well mean"
end


"Calculate deconvolution matrix K for each well"
function calc_kinv(
    ::Type{Val{well_proc_vec}},
    smw             ::SArray{S,<: Float_T,3} where {S},
    dyes            ::SVector{L,Int_T},
    wells           ::SVector{M,Symbol} where {M}
) where {L}
    singular_wells = Vector{Symbol}()
    k_s =
        map(eachindex(wells)) do wi
            map(eachindex(dyes)) do dye
                sweep(sum)(/)(smw[:, dye, wi])
            end #= next dye =# |>
            gather(hcat)
        end ## next wi
    k_inv_vec =
        map(eachindex(wells)) do wi
            try
                ## `inv()` is supposedly faster with StaticArray
                inv(k_s[wi])
            catch err
                if  isa(err, Base.LinAlg.SingularException) ||
                    isa(err, Base.LinAlg.LAPACKException)
                        push!(singular_wells, wells[wi])
                        pinv(k_s[wi])
                else
                    rethrow(err)
                end ## if isa(err
            end ## try
        end ## next wi
    inv_note = (length(singular_wells) > 0) ?
        "Well(s) " * string(join(singular_wells, ", ")) : ""
    return k_s, k_inv_vec, inv_note
end


#==============================================================================#


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
#     dyes_to_fill ::AbstractVector =[]
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
#     #     parse(Int_T, split(cd_key, "_")[2])
#     # end
#
#     const ary2dcv_1 =
#         cat(1,
#             map(values(calib_dict_1)) do value_1
#                 reshape(transpose(fluo_data), 1, size(value_1[1],2,1)...)
#             end...) ## do value_1
#     const (background_subtracted_data_1, k4dcv_2, deconvoluted_data_1,
#         norm_data_2, norm_well_nums_2, calibrated_data_1) =
#         calibrate(
#             ary2dcv_1,
#             db_conn_2,
#             calib_info_2,
#             well_nums_2,
#             well_nums_2,
#             channel_nums_1,
#             true,
#             dye_in,
#             dyes_to_fill;
#             data_format = array)
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
## get all the data from a calibration experiment,
## including data from all the channels for all the steps
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
#        parse(Int_T, split(cd_key, "_")[2])
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
#            error(logger, "experiment $exp_id, step $step_id: " *
#                " calibration data is not found for all the wells requested")
#        end ## if
#        calib_data_1key_chwl = vcat(map(channel_nums) do channel
#            transpose(calib_data_1key[:fluorescence_value][calib_data_1key[:channel] .== channel])
#        end...) ## do channel
#            return an array where rows indexed by channels and columns indexed by wells
#
#        return calib_key => (calib_data_1key_chwl, calib_well_nums)
#    end)
#
#    return calib_dict ## share the same keys as `calib_info`
#
# end ## get_full_calib_data
