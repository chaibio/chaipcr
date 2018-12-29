@time __precompile__()
module MySQLforQpcrAnalysis

import DataStructures.OrderedDict

## for MySQL versions outputing named tuples by default instead of data frames
## supposedly, "To get the results as a DataFrame, you can just do MySQL.query(conn, sql, DataFrame)",
## but there was some challenges that i don't remember exactly
# using Compat, NamedTuples
# nt1 = @NT(a=[1,2],b=[3,4])
# DataFrame(OrderedDict(Compat.pairs(nt1)))


using DataFrames, DataStructures, JSON, MySQL


# constants

const STEP_NAME_to_CALIB_DATA_KEY = OrderedDict(
    "calib_single" => OrderedDict(
        "Water" => "water",
        "Signal" => "channel_1"
    ),
    "calib_dual" => OrderedDict(
        "Water" => "water",
        "FAM" => "channel_1",
        "HEX" => "channel_2"
    ),
    "ot_single" => OrderedDict(
        "LED off" => "baseline",
        "LED on" => "excitation"
    ),
    "ot_dual" => OrderedDict(
        "Baseline" => "baseline",
        "Water" => "water",
        "FAM" => "channel_1",
        "HEX" => "channel_2",
    )
)




# functions


# top-level
function id2json(
    db_conn ::MySQL.MySQLHandle,
    action ::String; # calib_like, amplification, meltcurve, analyze
    guid ::String="",
    # 0 is not valid
    exp_id ::Integer=0,
    calib_id ::Integer=0,
    stage_id ::Integer=0,
    step_id ::Integer=0,
    ramp_id ::Integer=0,
    well_nums ::Vector=[],
    step_name_to_calib_data_key ::OrderedDict{String,OrderedDict{String,String}}=STEP_NAME_to_CALIB_DATA_KEY
    )

    # sanity check and resolving id if necessary
    if action == "calib_like" && guid == "" # for a calibration experiment not part of an `analyze` call, if `calib_id == 0` use `exp_id` to infer `calib_id`, at the end use `calib_id` as `exp_id` for further processing.
        if calib_id == 0
            if exp_id == 0
                error("One of exp_id and calib_id must be valid (not 0) when retrieving calibration data.")
            else
                exp2calib_qry = "SELECT id, calibration_id FROM experiments WHERE id = $exp_id"
                calib_id = MySQL.mysql_execute(db_conn, exp2calib_qry)[1][:calibration_id][1]
                println("calib_id not specified, inferred from exp_id as $calib_id.")
            end
        end
        exp_id = calib_id
    elseif exp_id == 0
        error("exp_id must be valid except when retrieving calibration information not used for \"analyze\".")
    end

    well_constraint = length(well_nums) == 0 ? "" : "AND well_num in ($(join(well_nums, ",")))"

    data = nothing


    # find steps

    step_ramp_qry = "SELECT DISTINCT
            steps.id AS step_id,
            steps.name AS step_name,
            steps.collect_data AS step_collect_data,
            ramps.id AS ramp_id,
            ramps.collect_data AS ramp_collect_data
        FROM experiments
            LEFT JOIN protocols ON experiments.experiment_definition_id = protocols.experiment_definition_id
            LEFT JOIN stages ON protocols.id = stages.protocol_id
            LEFT JOIN steps ON stages.id = steps.stage_id
            LEFT JOIN ramps ON steps.id = ramps.next_step_id
        WHERE
                experiments.id = $exp_id
            AND stages.stage_type <> \'meltcurve\'
        ORDER BY step_id
    "
    step_ramp_qry_res = MySQL.mysql_execute(db_conn, step_ramp_qry)[1]
    step_count = length(step_ramp_qry_res[:step_id])

    # collect all the steps, not just useful ones (e.g. Water, Signal, FAM, HEX)
    exp_steps = OrderedDict(
        begin
            step_name_tmp = step_ramp_qry_res[:step_name][i]
            step_id_tmp = step_ramp_qry_res[:step_id][i]
            step_name_adj = ismissing(step_name_tmp) ? "missing_$step_id_tmp" : step_name_tmp
            step_name_adj => step_id_tmp
        end
        for i in 1:step_count
    )
    println("exp_steps: $exp_steps")

    # process according to action

    if action == "analyze"
        if guid in ("optical_cal", "optical_test_single_channel", "optical_test_dual_channel")
            action = "calib_like"
        elseif guid == "thermal_consistency"
            action = "meltcurve"
            stage_id = 4
        elseif guid == "thermal_performance_diagnostic"
            data_qry = "
            SELECT
                    heat_block_zone_1_temp,
                    heat_block_zone_2_temp,
                    elapsed_time,
                    lid_temp
                FROM temperature_logs
                WHERE experiment_id = $exp_id
                ORDER BY elapsed_time
            "
        end # guid
    end # action == "analyze"


    # separate from `if action == "analyze"` because need to consider `action` updated during `if action == "analyze"`

    if action == "amplification"

        if step_id == 0 && ramp_id == 0
            println("step(s) where data is collected on the step or the ramp leading up to the step:")
            for i in 1:step_count
                step_collect_data = step_ramp_qry_res[:step_collect_data][i]
                ramp_collect_data = step_ramp_qry_res[:ramp_collect_data][i]
                if step_collect_data == 1 || ramp_collect_data == 1
                    step_id = step_ramp_qry_res[:step_id][i]
                    ramp_id = step_ramp_qry_res[:ramp_id][i]
                    step_name = step_ramp_qry_res[:step_name][i]
                    cyc_qry = "
                        SELECT DISTINCT cycle_num
                            FROM fluorescence_data
                            WHERE
                                    experiment_id = $exp_id
                                AND (step_id = $step_id
                                OR ramp_id = $ramp_id)
                                $well_constraint
                    "
                    cyc_res = MySQL.mysql_execute(db_conn, cyc_qry)[1]
                    num_cycles = length(cyc_res[:cycle_num])
                    #
                    info_clause = "info on the $(i)th step of this exp"
                    println("
                        $info_clause, start {
                        number of cycles - $num_cycles,
                        step_id - $step_id,
                        step_collect_data - $step_collect_data,
                        ramp_id - $ramp_id,
                        ramp_collect_data - $ramp_collect_data,
                        step_name - $step_name
                        } end, $info_clause
                    ")
                end # if step_collect_data
            end # for i
            error("step_id and ramp_id cannot be 0 at the same time for amplification. please consider using the information above to specify a step_id or ramp_id")

        elseif step_id != 0 && ramp_id != 0
            error("neither step_id or ramp_id is 0, it is unclear which one should be used. please specify only one as non-0 and the other as 0.")

        elseif step_id != 0 && ramp_id == 0
            step_ramp_constraint = "step_id = $step_id"

        elseif step_id == 0 && ramp_id != 0
            step_ramp_constraint = "ramp_id = $ramp_id"

        end # if step_id

        data_qry = "
        SELECT fluorescence_value, well_num, cycle_num, channel
            FROM fluorescence_data
            WHERE
                    experiment_id = $exp_id
                AND $step_ramp_constraint
                $well_constraint
            ORDER BY channel, well_num, cycle_num
        "

    elseif action == "meltcurve"
        if stage_id == 0
            stage_qry = "SELECT DISTINCT stages.id AS stage_id
                FROM experiments
                    LEFT JOIN protocols ON experiments.experiment_definition_id = protocols.experiment_definition_id
                    LEFT JOIN stages ON protocols.id = stages.protocol_id
                WHERE
                        experiments.id = $exp_id
                        AND stages.stage_type = \'meltcurve\'
            "
            println(MySQL.mysql_execute(db_conn, stage_qry)[1])
            error("stage_id must be valid for meltcurve. please consider the information above and specify a stage_id.")
        end
        data_qry = "
        SELECT well_num, temperature, fluorescence_value, channel
            FROM melt_curve_data
            WHERE
                    experiment_id = $exp_id
                AND stage_id = $stage_id
                $well_constraint
            ORDER BY channel, well_num, temperature
        "

    elseif action == "calib_like" # compute data
        # get data
        if guid == "optical_test_single_channel"
            step_config = "ot_single"
        elseif guid == "optical_test_dual_channel"
            step_config = "ot_dual"
        elseif "Signal" in keys(exp_steps)
            step_config = "calib_single"
        else
            step_config = "calib_dual"
        end # if guid
        data = OrderedDict(
            pair.second => begin
                step_id = exp_steps[pair.first]
                data_qry = "SELECT fluorescence_value, channel
                    FROM fluorescence_data
                    WHERE
                            experiment_id = $exp_id
                        AND step_id = $step_id
                        $well_constraint
                        AND cycle_num = 1
                	ORDER BY channel, well_num
                "
                step_data_raw = MySQL.mysql_execute(db_conn, data_qry)[1]
                if step_config in ("calib_single", "ot_single")
                    step_data = [step_data_raw[:fluorescence_value], nothing]
                elseif step_config in ("calib_dual", "ot_dual")
                    step_data = map(unique(step_data_raw[:channel])) do channel_num
                        step_data_raw[:fluorescence_value][step_data_raw[:channel] .== channel_num]
                    end # do channel_num
                end # if
                step_data # to return
            end # begin
            for pair in step_name_to_calib_data_key[step_config]
        )

    end # if action


    if data == nothing # data was not computed during `if action`. currently equivalent to `action != "calib_like"`
        data_qry_res = MySQL.mysql_execute(db_conn, data_qry)[1]
        data = OrderedDict(
            string(coln) => map(data_qry_res[coln]) do val
                ismissing(val) ? nothing : val
            end # do val
            for coln in data_qry_res.colindex.names # assuming qry_res is a DataFrame. need to change if `qry_res` is a NamedTuple
        )
    end # if data

    # return data # for testing
    return JSON.json(data)

end # id2json

    




end # module MySQLforQpcrAnalysis




#
