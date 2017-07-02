#

function dispatch(action::String, request_body::String)

    req_dict = JSON.parse(request_body; dicttype=OrderedDict) # Julia 0.4.6, DataStructures 0.4.4. DefautlDict and DefaultOrderedDict constructors sometimes don't work on OrderedDict (https://github.com/JuliaLang/DataStructures.jl/issues/205)
    keys_req_dict = keys(req_dict)

    calib_info = "calibration_info" in keys_req_dict ? req_dict["calibration_info"] : calib_info_AIR

    db_name = "db_name" in keys_req_dict ? req_dict["db_name"] : db_name_AIR
    db_conn = "db_key" in keys_req_dict ? DB_CONN_DICT[req_dict["db_key"]] : ((db_name == db_name_AIR) ? DB_CONN_DICT["default"] : mysql_connect(
        req_dict["db_host"], req_dict["db_usr"], req_dict["db_pswd"], req_dict["db_name"]
    ))
    # println("non-default db_name: ", db_name)

    result = try
        if action == "amplification"
            exp_id = req_dict["experiment_id"]
            if "step_id" in keys_req_dict
                asrp_vec = [AmpStepRampProperties("step", req_dict["step_id"], DEFAULT_cyc_nums)]
            elseif "ramp_id" in keys_req_dict
                asrp_vec = [AmpStepRampProperties("ramp", req_dict["ramp_id"], DEFAULT_cyc_nums)]
            else
                asrp_vec = Vector{AmpStepRampProperties}()
            end
            baseline_cyc_bounds = "baseline_cyc_bounds" in keys_req_dict ? reshape_lv(req_dict["baseline_cyc_bounds"], 1) : []
            cq_method = "cq_method" in keys_req_dict ? req_dict["cq_method"] : "Cy0"
            process_amp( # can't use `return` to return within `try`
                db_conn, exp_id, asrp_vec, calib_info;
                min_reliable_cyc=req_dict["min_ct"],
                baseline_cyc_bounds=baseline_cyc_bounds,
                cq_method=cq_method,
                out_sr_dict=false
            )
        elseif action == "meltcurve" # may need to change to process only 1-channel before deployed on bbb
            exp_id = req_dict["experiment_id"]
            stage_id = req_dict["stage_id"]
            process_mc(
                db_conn, exp_id, stage_id,
                calib_info;
            )
        elseif action == "analyze"
            exp_info = req_dict["experiment_info"]
            exp_id = exp_info["id"]
            guid = exp_info["guid"]
            analyze_func(
                Analyze_DICT[guid](), db_conn, exp_id, calib_info;
            )
        else
            error("action $action is not found")
        end # if
    catch err
        err
    end # try

    success = !isa(result, Exception)
    response_body = success ? result : json(OrderedDict("error"=>result))

    if db_name != db_name_AIR
        mysql_disconnect(db_conn)
    end

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
        reqb["min_ct"] = min_reliable_cyc
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
