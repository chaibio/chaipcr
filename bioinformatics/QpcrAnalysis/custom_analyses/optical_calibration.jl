#===============================================================================

    optical_calibration.jl

    uses prep_normalize() to check validity of calibration data

===============================================================================#

import DataStructures.OrderedDict
import Memento.debug


#===============================================================================
    function definition >>
===============================================================================#

## called by dispatch()
function act(
    ::Type{Val{optical_calibration}},
    req_dict            ::Associative;
    out_format          ::OutputFormat = pre_json_output,

    ## remove MySql dependency  
    #
    # db_conn::MySQL.MySQLHandle,
    # exp_id::Integer, ## not used for computation
    # calib_info::Union{Integer,OrderedDict}; ## really used
)
    debug(logger, "at act(::Type{Val{optical_calibration}})")
 
    ## remove MySql dependency
    # calib_info_ori = calib_info
    # calib_info_dict = ensure_ci(db_conn, calib_info_ori)
    # print_v(
    #     println, verbose,
    #     "original: ", calib_info_ori,
    #     "dict: ", calib_info_dict
    # )

    ## calibration data is required
    if !(haskey(req_dict, CALIBRATION_INFO_KEY) &&
        isa(req_dict[CALIBRATION_INFO_KEY], Associative))
            return fail(logger, ArgumentError(
                "no calibration information found")) |> out(out_format)
    end
    const calibration = CalibrationData(req_dict[CALIBRATION_INFO_KEY])
    const wells = try
        prep_normalize(
            calibration,
            DEFAULT_CAL_DYE_IN,
            DEFAULT_CAL_DYES_TO_FILL)[2]
    catch err
        return fail(logger, err; bt=true) |> out(out_format)
    end
    if (size(calibration.data, 2) == 2)
        ## if there are 2 or more channels then
        ## the deconvolution matrix K is calculated
        ## otherwise deconvolution is not performed
        const result_k = try
            get_k(
                calibration,
                eachindex(wells),
                wells,
                DEFAULT_DCV_K_METHOD)
        catch err
            return fail(logger, err; bt=true) |> out(out_format)
        end
        (length(result_k.inv_note) > 0) &&
            return fail(logger, result_k.inv_note) |> out(out_format)
    end ## if
    return OrderedDict(:valid => true) |> out(out_format)
end ## act(::Type{Val{optical_calibration}})
