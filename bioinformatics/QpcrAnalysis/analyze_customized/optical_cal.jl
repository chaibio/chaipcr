# optical_cal.jl
# use `prep_adj_w2wvaf` to check validity of calibration data for adjusting well-to-well variation in absolute fluo

# check JSON output in UI: http://:ip_address/experiments/:exp_id/analyze

import DataStructures.OrderedDict
import JSON

# called by QpcrAnalyze.dispatch
function act(
    ::OpticalCal,
    calib_info_dict ::Associative;

    # new >>
    well_nums ::AbstractVector =[],
    out_format ::String ="pre_json",
    verbose ::Bool =false,
    # << new

    ## remove MySql dependency  
    #
    # db_conn::MySQL.MySQLHandle,
    # exp_id::Integer, # not used for computation
    # calib_info::Union{Integer,OrderedDict}; # really used

    dye_in ::String ="FAM", 
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

    result = OrderedDict("valid" => true)
    err_msg_vec = Vector{String}()

    # get_k

    if length(calib_info_dict) >= 3 # 2 or more channels

        result_k = # try

        ## remove MySql dependency
        #
        #    get_k(db_conn, calib_info_dict, well_nums)

            get_k(calib_info_dict, well_nums)
            
        # catch err
        #     err
        # end

        if isa(result_k, Exception)
            err_msg = isa(result_k, ErrorException) ? result_k.msg : "$(string(result_k)). "
            push!(err_msg_vec, "K matrix: $err_msg")
        else
            inv_note = result_k.inv_note
            if length(inv_note) > 0
                push!(err_msg_vec, inv_note)
            end # if length
        end # if isa

    end # if length

    # prep_adj_w2wvaf

    result_aw = # try

        ## remove MySql dependency
        #
        # prep_adj_w2wvaf(db_conn, calib_info_dict, well_nums, dye_in, dyes_2bfild)

        # new >>
        prep_adj_w2wvaf(calib_info_dict, well_nums, dye_in, dyes_2bfild)
        # << new
        
    # catch err
    #     err
    # end

    if isa(result_aw, Exception)
        err_msg = isa(result_aw, ErrorException) ? result_aw.msg : "$(string(result_aw)). "
        push!(err_msg_vec, err_msg)
    end

    # I think the cleanest thing is to not have an error_message at all if it is the success case
    if length(err_msg_vec) > 0
        result = OrderedDict(
            "valid" => false,
            "error_message" => join(err_msg_vec, "")
        )
    end

    if (out_format=="json")
        result = JSON.json(result) # become a string
    end

    return result

end # optical_calibration






#
