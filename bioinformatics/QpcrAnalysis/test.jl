# test


""" items to be tested

all:
    single channel
    dual channel
    all wells, selected wells
    dcv == true or false
    output:
        full, pre-json, json
        elements and formats (type, dimension)
        values make sense (minus water, dcv, aw, blsub)
        plots
    end: output
end: all


amplification:
    data with cycles 1 through `min_reliable_cyc + 2`, 1000
end: amplification.

melt curve:
    1 tmprtr point with missing data, 2-4 tmprtr points, all available tmprtr
end: melt curve

calib_calib:
    whether output makes sense
end: calib_calib

deconv:
    well_proc = "vec" vs. "mean"
end: deconv


analyze functions

analyze_optical_calibration
    both single- and multi-channel: valid vs. invalid for adjusting w2w
    multi-channel only: valid vs. invalid for k matrix
end: analyze_optical_calibration

end: analyze functions


end: items to be tested"""




# constants

immutable TestDBInfo # need to load each sqldump file named "$db_name_src.sql" as an MySQL database named "db_name"
    db_name::String
    db_name_src::String
    exp_ids::OrderedDict
end

const TD_INFO_DICT = OrderedDict(
    "t1" => TestDBInfo(
        "test_1ch",
        "20160825_chaipcr_ip201",
        OrderedDict(
            "amplification"=>169,
            "calibration"=>168,
            "meltcurve"=>170,
            "optical_test_single_channel"=>161,
            "thermal_consistency"=>146,
            "thermal_performance_diagnostic"=>126
        )
    ),
    "t2" => TestDBInfo(
        "test_2ch",
        "20160720_chaipcr_ip223",
        OrderedDict(
            "amplification"=>222,
            "calibration"=>219,
            "meltcurve"=>223,
            "optical_test_dual_channel"=>190,
            "thermal_consistency"=>145,
            "thermal_performance_diagnostic"=>131
        )
    )
)

const CHANNEL_SETUP_DICT = OrderedDict(
    "t1"=>"single_channel",
    "t2"=>"dual_channel"
)


function test(;
    comprehensive::Bool=false,
    debug::Bool=true,
    verbose::Bool=false
    )

    OrderedDict(map(keys(TD_INFO_DICT)) do td_key

        tr_cs = OrderedDict{String,Any}() # test_results_channel_setup

        channel_setup = CHANNEL_SETUP_DICT[td_key]
        print_v(println, verbose, "$channel_setup tests:")

        db_conn = DB_CONN_DICT[td_key]

        td_info = TD_INFO_DICT[td_key]
        exp_ids = td_info.exp_ids

        calib_info = ensure_ci(db_conn, exp_ids["calibration"])

        reqb_kwargs = OrderedDict(:wdb=>"handle", :db_key=>td_key)

        # MySQL
        db_qry = "select * from experiments"
        tr_cs["mysql"] = MySQL.mysql_execute(db_conn, db_qry)[1]
        print_v(println, verbose, "Passed: MySQL \"select * from users\".")


        for action in ["amplification", "meltcurve"]

            exp_id = exp_ids[action]

            stage_qry = "SELECT stages.id FROM experiments
                LEFT JOIN protocols ON experiments.experiment_definition_id = protocols.experiment_definition_id
                LEFT JOIN stages ON protocols.id = stages.protocol_id
                WHERE experiments.id = $exp_id AND stages.stage_type <> \'holding\'
            "
            stage_id = unique(MySQL.mysql_execute(db_conn, stage_qry)[1][:id])[1]

            if debug
                if action == "amplification"
                    amp_debug = process_amp(db_conn, exp_id, Vector{AmpStepRampProperties}(), calib_info)
                elseif action == "meltcurve"
                    mc_debug = process_mc(db_conn, exp_id, stage_id, calib_info)
                end # if action
            end # if debug

            reqb = args2reqb(action, exp_id, calib_info; stage_id=stage_id, reqb_kwargs...)
            tr_cs[action] = dispatch(action, reqb)

            print_v(println, verbose, "Passed: $action")

        end # for


        action = "analyze"

        tr_cs[action] = OrderedDict(map(["optical_cal", "optical_test", "thermal_consistency", "thermal_performance_diagnostic"]) do guid_pre

            guid = (guid_pre == "optical_test") ? "$(guid_pre)_$channel_setup" : guid_pre

            exp_key = (guid == "optical_cal") ? "calibration" : guid
            exp_id = exp_ids[exp_key]

            calib_info_anlz = (guid == "optical_test_dual_channel") ? begin
                step_names = ["baseline", "water", "channel_1", "channel_2"]
                step_qry = "SELECT step_id from fluorescence_data WHERE experiment_id = $exp_id"
                step_ids = sort(unique(MySQL.mysql_execute(db_conn, step_qry)[1][:step_id])) # assuming the order fits that in `step_names`
                OrderedDict(map(1:4) do i
                    step_names[i] => OrderedDict(
                        "calibration_id" => exp_id,
                        "step_id" => step_ids[i]
                    )
                end) # do i
            end : calib_info

            if debug
                anlz_debug = analyze_func(GUID2Analyze_DICT[guid](), db_conn, exp_id, calib_info_anlz)
            end

            reqb = args2reqb(
                action, exp_id, calib_info_anlz;
                guid=guid, reqb_kwargs...
            )
            return_pair = guid => dispatch(action, reqb)
            print_v(println, verbose, "Passed: $action.$guid")
            return_pair

        end) # do guid_pre


        return channel_setup => tr_cs

    end) # do td_key

end




#
