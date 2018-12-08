# dispatch.jl

import JSON, DataStructures.OrderedDict

function dispatch(action::String, request_body::String)
    
    # NB. DefaultDict and DefaultOrderedDict constructors sometimes don't work on OrderedDict
    # (https://github.com/JuliaLang/DataStructures.jl/issues/205)
    req_parsed = JSON.parse(request_body; dicttype=OrderedDict)

    if isa(req_parsed, Associative) # amplification, meltcurve, analyze
        req_dict = req_parsed
        keys_req_dict = keys(req_dict)

        ## remove MySql dependency
        #
        # calib_info = "calibration_info" in keys_req_dict ? req_dict["calibration_info"] : calib_info_AIR
        #
        # db_name = "db_name" in keys_req_dict ? req_dict["db_name"] : db_name_AIR
        # db_conn = "db_key" in keys_req_dict ? DB_CONN_DICT[req_dict["db_key"]] : ((db_name == db_name_AIR) ? DB_CONN_DICT["default"] : mysql_connect(
        #     req_dict["db_host"], req_dict["db_usr"], req_dict["db_pswd"], req_dict["db_name"]
        # ))
        ## println("non-default db_name: ", db_name)

    elseif isa(req_parsed, AbstractVector) # standard_curve
        req_vec = req_parsed

        ## remove MySql dependency
        #
        # db_name = db_name_AIR

    end # if isa

    result = try

        if action == "amplification"

            # new >>
            # validate data format
            test = try
                amplification_request_test(req_dict)
            catch err
               error("data supplied with amplification request is in the wrong format")
            end
            # << new

            ## remove MySql dependency
            #
            ## asrp_vec
            # if "step_id" in keys_req_dict
            #     asrp_vec = [AmpStepRampProperties("step", req_dict["step_id"], DEFAULT_cyc_nums)]
            # elseif "ramp_id" in keys_req_dict
            #     asrp_vec = [AmpStepRampProperties("ramp", req_dict["ramp_id"], DEFAULT_cyc_nums)]
            # else
            #     asrp_vec = Vector{AmpStepRampProperties}()
            # end

            # new >>
            ## we will assume that any relevant step/ramp information has already been passed along
            ## and is present in step_id / ramp_id
            if "step_id" in keys_req_dict
                asrp_vec = [AmpStepRampProperties("step", req_dict["step_id"], DEFAULT_cyc_nums)]
            elseif "ramp_id" in keys_req_dict
                asrp_vec = [AmpStepRampProperties("ramp", req_dict["ramp_id"], DEFAULT_cyc_nums)]
            else
                error("no step/ramp information found")
            end
            # << new

            # `report_cq!` arguments
            kwdict_rc = Dict{Symbol,Any}()
            if "min_fluomax" in keys_req_dict
                kwdict_rc[:max_bsf_lb] = req_dict["min_fluomax"]
            end
            if "min_D1max" in keys_req_dict
                kwdict_rc[:max_d1_lb] = req_dict["min_D1max"]
            end
            if "min_D2max" in keys_req_dict
                kwdict_rc[:max_d2_lb] = req_dict["min_D2max"]
            end

            # `process_amp_1sr` arguments
            kwdict_pa1 = Dict{Symbol,Any}()
            for key in ["min_reliable_cyc", "baseline_cyc_bounds", "cq_method", "ctrl_well_dict"]
                if key in keys_req_dict
                    kwdict_pa1[Symbol(key)] = req_dict[key]
                end
            end
            if "categ_well_vec" in keys_req_dict
                categ_well_vec = req_dict["categ_well_vec"]
                for i in 1:length(categ_well_vec)
                    if length(categ_well_vec[i][2]) == 0
                        categ_well_vec[i][2] = Colon()
                    end
                end
                kwdict_pa1[:categ_well_vec] = categ_well_vec
            end

            # `mod_bl_q` arguments
            kwdict_mbq = Dict{Symbol,Any}()
            if "baseline_method" in keys_req_dict
                baseline_method = req_dict["baseline_method"]
                if baseline_method == "sigmoid"
                    kwdict_mbq[:bl_method] = "l4_enl"
                    kwdict_mbq[:bl_fallback_func] = median
                elseif baseline_method == "linear"
                    kwdict_mbq[:bl_method] = "lin_1ft"
                    kwdict_mbq[:bl_fallback_func] = mean
                elseif baseline_method == "median"
                    kwdict_mbq[:bl_method] = "median"
                end
            end

            # call
            process_amp( # can't use `return` to return within `try`
                
                ## remove MySql dependency
                #
                # db_conn, exp_id, asrp_vec, calib_info;

                # new >>
                req_dict["raw_data"],
                req_dict["calibration_info"],
                asrp_vec;
                # << new

                kwdict_rc   = kwdict_rc,
                kwdict_mbq  = kwdict_mbq,
                out_sr_dict = false,
                kwdict_pa1...
            )

        elseif action == "meltcurve" # may need to change to process only 1-channel before deployed on bbb

            exp_id = req_dict["experiment_id"]
            stage_id = req_dict["stage_id"]
            kwdict_pmc = OrderedDict{Symbol,Any}()

            for key in ["channel_nums"]
                if key in keys_req_dict
                    kwdict_pmc[parse(key)] = req_dict[key]
                end
            end

            kwdict_mc_tm_pw = OrderedDict{Symbol,Any}()
            if "qt_prob" in keys_req_dict
                kwdict_mc_tm_pw[:qt_prob_flTm] = req_dict["qt_prob"]
            end
            if "max_normd_qtv" in keys_req_dict
                kwdict_mc_tm_pw[:normd_qtv_ub] = req_dict["max_normd_qtv"]
            end
            for key in ["top_N"]
                if key in keys_req_dict
                    kwdict_mc_tm_pw[parse(key)] = req_dict[key]
                end
            end

            process_mc(
                db_conn, exp_id, stage_id,
                calib_info;
                kwdict_pmc...,
                kwdict_mc_tm_pw=kwdict_mc_tm_pw
            )

        elseif action == "analyze"
            exp_info = req_dict["experiment_info"]
            exp_id = exp_info["id"]
            guid = exp_info["guid"]
            analyze_func(
                GUID2Analyze_DICT[guid](), db_conn, exp_id, calib_info;
            )

        elseif action == "standard_curve"
            standard_curve(req_vec)

        else
            error("action $action is not found")
        end # if

    catch err
        err
    end # try

    success = !isa(result, Exception)
    response_body = success ? result : JSON.json(OrderedDict("error"=>repr(result)))

    ## remove MySql dependency
    #
    # if db_name != db_name_AIR
    #     mysql_disconnect(db_conn)
    # end

    return (success, response_body)
end # dispatch


# get keyword arguments from request
function get_kw_from_req(key_vec::AbstractVector, req_dict::Associative)
    pair_vec = Vector{Pair}()
    for key in key_vec
        if key in keys(req_dict)
            push!(pair_vec, parse(key) => req_dict[key])
        end # if
    end # for
    return OrderedDict(pair_vec)
end


# testing function: construct `request_body` from separate arguments
function args2reqb(
    action::String,
    exp_id::Integer,
    calib_info::Union{Integer,OrderedDict};
    stage_id::Integer=0,
    step_id::Integer=0,
    ramp_id::Integer=0,
    min_reliable_cyc::Real=5,
    baseline_method::String="sigmoid",
    baseline_cyc_bounds::AbstractVector=[],
    guid::String="",
    extra_args::OrderedDict=OrderedDict(),
    wdb::String="dflt", # "handle", "dflt", "connect"
    db_key::String="default", # "default", "t1", "t2"
    db_host::String="localhost",
    db_usr::String="root",
    db_pswd::String="",
    db_name::String="chaipcr",
    )

    reqb = OrderedDict{typeof(""),Any}("calibration_info"=>calib_info)

    if action == "amplification"
        reqb["experiment_id"] = exp_id
        reqb["min_reliable_cyc"] = min_reliable_cyc
        reqb["baseline_cyc_bounds"] = baseline_cyc_bounds
        if step_id != 0
            reqb["step_id"] = step_id
        elseif ramp_id != 0
            reqb["ramp_id"] = ramp_id
        # else
        #     println("No step_id or ramp_id will be specified.")
        end
    elseif action == "meltcurve"
        reqb["experiment_id"] = exp_id
        reqb["stage_id"] = stage_id
    elseif action == "analyze"
        reqb["experiment_info"] = OrderedDict(
            "id"=>exp_id,
            "guid"=>guid
        )
    else
        error("Unrecognized action.")
    end

    for key in keys(extra_args)
        reqb[key] = extra_args[key]
    end

    if wdb == "handle"
        reqb["db_key"] = db_key
    elseif wdb == "dflt"
        nothing
    elseif wdb == "connect"
        reqb["db_host"] = db_host
        reqb["db_usr"] = db_usr
        reqb["db_pswd"] = db_pswd
        reqb["db_name"] = db_name
    else
        error("`wdb` must be one of the following: \"handle\", \"dflt\", \"connect\".")
    end

    return json(reqb)

end # args2reqb




# test: it works
function test0()
    println(guids)
end
#
