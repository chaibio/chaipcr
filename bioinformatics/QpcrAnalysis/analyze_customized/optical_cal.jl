## optical_cal.jl
#
## use `prep_adj_w2wvaf` to check validity of calibration data for adjusting well-to-well variation in absolute fluo

import DataStructures.OrderedDict
import JSON
import Memento.debug


## called by QpcrAnalyze.dispatch
function act(
    Val{optical_cal},
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
    debug(logger, "at act(Val{optical_cal})")
 
    ## remove MySql dependency
    # calib_info_ori = calib_info
    # calib_info_dict = ensure_ci(db_conn, calib_info_ori)
    # print_v(
    #     println, verbose,
    #     "original: ", calib_info_ori,
    #     "dict: ", calib_info_dict
    # )

    const err_msg =
        if !haskey(calib_info, CALIBRATION_INFO_KEY) || !(typeof(calib_info[CALIBRATION_INFO_KEY]) <: Associative)
        ## calibration data is required
            "no calibration information found"
        else
            const calib_info_dict = calib_info[CALIBRATION_INFO_KEY]
            const result_aw =
                try prep_adj_w2wvaf(calib_info_dict, well_nums, dye_in, dyes_2bfild)
                catch err
                    debug(logger, "catching error in act(Val{optical_cal})")
                    debug(logger, sprint(showerror, err, catch_backtrace()))
                end
            if isa(result_aw, Exception)
                ## return value
                sprint(showerror, result_aw)
            elseif (length(calib_info_dict) >= 3)
                ## get_k
                ## if there are 2 or more channels then
                ## the deconvoltion matrix K is calculate
                ## otherwise deconvolution is not performed
                const result_k =
                    try get_k(calib_info_dict, well_nums)
                    catch err
                        debug(logger, "catching error in act(Val{optical_cal})")
                        debug(logger, sprint(showerror, err, catch_backtrace()))
                    end
                if isa(result_k, Exception)
                    ## return value
                    sprint(showerror, result_k)
                elseif length(result_k.inv_note) > 0
                    ## return value
                    result_k.inv_note
                end ## if
            end ## if
        end ## err_msg

    const output =
        thing(err_msg) ?
            OrderedDict(
                :valid => false,
                :error => err_msg) :
            OrderedDict(
                :valid => true)
    return (out_format == :json) && JSON.json(output) || output
end ## optical_calibration()


#
