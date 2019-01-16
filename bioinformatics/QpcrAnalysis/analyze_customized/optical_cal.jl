## optical_cal.jl
#
## use `prep_adj_w2wvaf` to check validity of calibration data for adjusting well-to-well variation in absolute fluo

import DataStructures.OrderedDict
import JSON


## called by QpcrAnalyze.dispatch
function act(
    ::OpticalCal,
    calib_info  ::Associative;
    well_nums   ::AbstractVector =[],
    out_format  ::Symbol = :pre_json,
    verbose     ::Bool =false,
    ## remove MySql dependency  
    #
    # db_conn::MySQL.MySQLHandle,
    # exp_id::Integer, # not used for computation
    # calib_info::Union{Integer,OrderedDict}; # really used
    dye_in      ::Symbol = :FAM, 
    dyes_2bfild ::Vector =[]
)
    ## remove MySql dependency
    #
    # calib_info_ori = calib_info
    # calib_info_dict = ensure_ci(db_conn, calib_info_ori)

    # print_v(
    #     println, verbose,
    #     "original: ", calib_info_ori,
    #     "dict: ", calib_info_dict
    # )

    calib_info_dict = calib_info["calibration_info"]
    result = OrderedDict(:valid => true)
    err_msg_vec = Vector{String}()
    #
    ## prep_adj_w2wvaf
    result_aw = try
        ## remove MySql dependency
        #
        # prep_adj_w2wvaf(db_conn, calib_info_dict, well_nums, dye_in, dyes_2bfild)
        prep_adj_w2wvaf(calib_info_dict, well_nums, dye_in, dyes_2bfild)
    catch err
        err
    end
    if isa(result_aw, Exception)
        err_msg = isa(result_aw, ErrorException) ? result_aw.msg : "$(string(result_aw)). "
        push!(err_msg_vec, err_msg)
    elseif (length(calib_info_dict) >= 3)
        ## get_k
        ## if there are 2 or more channels then
        ## the deconvoltion matrix K is calculate
        ## otherwise deconvolution is not performed
        result_k = try
            ## remove MySql dependency
            #    get_k(db_conn, calib_info_dict, well_nums)
            get_k(calib_info_dict, well_nums)
        catch err
            err
        end
        if isa(result_k, Exception)
            err_msg = isa(result_k, ErrorException) ?
                result_k.msg :
                "$(string(result_k)). "
            push!(err_msg_vec, "K matrix: $err_msg")
        else
            inv_note = result_k.inv_note
            if length(inv_note) > 0
                push!(err_msg_vec, inv_note)
            end # if length
        end # if isa
    end # if length
    #
    ## report valid in success case
    if (length(err_msg_vec) > 0)
        result = OrderedDict(
            :valid => false,
            :error => join(err_msg_vec, "")
        )
    end
    #
    if (out_format == :json)
        result = JSON.json(result) # become a string
    end
    return result
end # optical_calibration()






#
