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

    ## calibration data is required
    if has_calibration_info(req_dict)
        return fail(logger, ArgumentError(
            "no calibration information found")) |> out(out_format)
    end
    #
    ## make CalibrationInput struct with default analysis parameters
    const calibration_data  = CalibrationData(req_dict[CALIBRATION_INFO_KEY])
    const calibration_input = CalibrationInput(calibration_data)
    #
    ## check validity of data for normalization
    const wells = try
        prep_normalize(calibration_input)[2]
    catch err
        return fail(logger, err; bt=true) |> out(out_format)
    end
    #
    ## check validity of data for deconvolution
    if isa(calibration_data, CalibrationData{DualChannel,<: Real})
        ## if there are 2 or more channels then
        ## the deconvolution matrix K is calculated
        ## otherwise deconvolution is not performed
        const result_k = try
            get_k(
                calibration_input,
                eachindex(wells),
                wells)
        catch err
            return fail(logger, err; bt=true) |> out(out_format)
        end
        (length(result_k.inv_note) > 0) &&
            return fail(logger, result_k.inv_note) |> out(out_format)
    end ## if
    #
    return OrderedDict(:valid => true) |> out(out_format)
end ## act(::Type{Val{optical_calibration}})
