## optical_cal.jl
#
## use `prep_adj_w2wvaf` to check validity of calibration data for adjusting well-to-well variation in absolute fluo

import DataStructures.OrderedDict
import JSON.json
import Memento.debug


## called by QpcrAnalyze.dispatch
function act(
    ::Val{optical_calibration},
    calib_info  ::Associative;
    well_nums   ::AbstractVector =[],
    out_format  ::Symbol = :pre_json,
    ## remove MySql dependency  
    #
    # db_conn::MySQL.MySQLHandle,
    # exp_id::Integer, ## not used for computation
    # calib_info::Union{Integer,OrderedDict}; ## really used
    dye_in      ::Symbol = :FAM, 
    dyes_2bfild ::Vector =[]
)
    debug(logger, "at act(::Val{optical_calibration})")
 
    ## remove MySql dependency
    # calib_info_ori = calib_info
    # calib_info_dict = ensure_ci(db_conn, calib_info_ori)
    # print_v(
    #     println, verbose,
    #     "original: ", calib_info_ori,
    #     "dict: ", calib_info_dict
    # )

    ## calibration data is required
    haskey(calib_info, CALIBRATION_INFO_KEY) &&
       typeof(calib_info[CALIBRATION_INFO_KEY]) <: Associative ||
            return fail(logger,
                        ArgumentError("no calibration information found"),
                        out_format)
    const calib_info_dict = calib_info[CALIBRATION_INFO_KEY]
    const result_aw =
        try prep_adj_w2wvaf(
            calib_info_dict, well_nums, dye_in, dyes_2bfild)
        catch err
            return fail(logger, err, out_format, bt=true)
        end
    if (length(calib_info_dict) >= 3)
        ## get_k
        ## if there are 2 or more channels then
        ## the deconvolution matrix K is calculated
        ## otherwise deconvolution is not performed
        const result_k =
            try get_k(calib_info_dict, well_nums)
            catch err
                return fail(logger, err, out_format, bt=true)
            end
        (length(result_k.inv_note) > 0) &&
            return fail(logger, result_k.inv_note, out_format)
    end ## if

    const output = OrderedDict(:valid => true)
    return (out_format == :json) && JSON.json(output) || output
end ## optical_calibration()


#
