#===============================================================================

    optical_calibration.jl

    uses prep_normalize() and get_k() with default parameters
    to check validity of calibration data

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

    ## get calibration data and use default analysis parameters
    if !calibration_info_in_req(req_dict)
        return fail(logger, ArgumentError(
            "no calibration data in request")) |> out(out_format)
    end
    const calibration_data = get_calibration_data(req_dict)
    const calibration_args = CalibrationParameters()
    #
    ## check validity of data for normalization
    const wells = try
        prep_normalize(calibration_data)[2]
    catch err
        return fail(logger, err; bt = true) |> out(out_format)
    end
    #
    ## check validity of data for deconvolution
    if isa(calibration_data, CalibrationData{DualChannel,<: Real})
        ## if there are 2 or more channels then
        ## the deconvolution matrix K is calculated
        ## otherwise deconvolution is not performed
        const result_k = try
            get_k(
                calibration_data,
                calibration_args,
                eachindex(wells),
                wells)
        catch err
            return fail(logger, err; bt = true) |> out(out_format)
        end
        (length(result_k.inv_note) > 0) &&
            return fail(logger, result_k.inv_note) |> out(out_format)
    end ## if
    #
    return OrderedDict(:valid => true) |> out(out_format)
end ## act(::Type{Val{optical_calibration}})
