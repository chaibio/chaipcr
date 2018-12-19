# dispatch.jl

import JSON, DataStructures.OrderedDict


function dispatch(
    action ::AbstractString,
    request_body ::AbstractString;

    verbose ::Bool =false,
    verify  ::Bool =false
)
    result = try

        # NB. DefaultDict and DefaultOrderedDict constructors sometimes don't work on OrderedDict
        # (https://github.com/JuliaLang/DataStructures.jl/issues/205)
        req_parsed = JSON.parse(request_body; dicttype=OrderedDict)

        if !(action in keys(Action_DICT))
            error("action $action is not found")
        end

        # else
        action_t = Action_DICT[action]()

        if (!PRODUCTION_MODE)
            if (verify)
                verify_input = try
                    verify_request(action_t, req_parsed)
                catch err
                    error("data supplied with $action request is in the wrong format")
                end
            end
        end

        response = act(action_t, req_parsed; out_format="pre_json", verbose=verbose)
        json_response=JSON.json(response)

        if (!PRODUCTION_MODE)
            if (verify)
                verify_output = try
                    verify_response(action_t,JSON.parse(json_response,dicttype=OrderedDict))
                catch err
                   error("data returned from $action request is in the wrong format")
                end
            end
        end

        String(json_response)

    catch err
        err
    end

    success = !isa(result, Exception)
    response_body = success ? result : String(JSON.json(Dict(:error => repr(result))))

    return (success, response_body)
end # dispatch


# get keyword arguments from request
function get_kw_from_req(key_vec ::AbstractVector, req_dict ::Associative)
    pair_vec = Vector{Pair}()
    for key in key_vec
        if key in keys(req_dict)
            push!(pair_vec, Symbol(key) => req_dict[key])
        end # if
    end # for
    return OrderedDict(pair_vec)
end


# testing function: construct `request_body` from separate arguments
function args2reqb(
    action ::String,
    exp_id ::Integer,
    calib_info ::Union{Integer,OrderedDict};
    stage_id ::Integer =0,
    step_id ::Integer =0,
    ramp_id ::Integer =0,
    min_reliable_cyc ::Real =5,
    baseline_method ::String ="sigmoid",
    baseline_cyc_bounds ::AbstractVector =[],
    guid ::String ="",
    extra_args ::OrderedDict =OrderedDict(),
    wdb ::String ="dflt", # "handle", "dflt", "connect"
    db_key ::String ="default", # "default", "t1", "t2"
    db_host ::String ="localhost",
    db_usr ::String ="root",
    db_pswd ::String ="",
    db_name ::String ="chaipcr",
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
            "id"   => exp_id,
            "guid" => guid
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
        reqb["db_usr"]  = db_usr
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
