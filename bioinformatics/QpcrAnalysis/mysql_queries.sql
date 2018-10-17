
-- MySQL queries for data as input to Julia

-- It'll be best if Rails code is designed to easily accommodate changes to these queries in future.
-- Assuming: before Rails passes data to Julia as JSON, it converted the table returned by SQL query into an associative of name-value pairs, where each pair represents a column in the table, i.e. name is the column header (e.g. "step_id"), value is a vector of the data (e.g. [1,1,2,2,2,3])
--
-- e.g.
-- This table below
-- step_id well_num
--       1        1
--       1        2
--       2        3
--       2        4
--       2        5
--       3        6
-- is converted to...
-- JSON {"step_id":[1,1,2,2,2,3],"well_num":[1,2,3,4,5,6]}

-- it can be easily converted to data frame in Julia via `DataFrame(JSON.parse("some_json_in_aforementioned_format"))`


-- queries depend on action


-- calibration, 1 query. needed for amplification, melt curve, and analyze thermal consistency
-- analyze_customized/optical_cal.jl, adj_w2wvaf.jl, calib.jl
SELECT step_id, fluorescence_value, well_num, cycle_num, channel
    FROM fluorescence_data
    WHERE experiment_id = $calib_id
;


-- amplification, 3 queries: calibration query and ...
-- $exp_id is the experiment_id for the amplification experiment
-- amp.jl

-- amplification, step/ramp info
SELECT
        steps.id AS steps_id,
        steps.collect_data AS steps_collect_data,
        ramps.id AS ramps_id,
        ramps.collect_data AS ramps_collect_data
    FROM experiments
    LEFT JOIN protocols ON experiments.experiment_definition_id = protocols.experiment_definition_id
    LEFT JOIN stages ON protocols.id = stages.protocol_id
    LEFT JOIN steps ON stages.id = steps.stage_id
    LEFT JOIN ramps ON steps.id = ramps.next_step_id
    WHERE
        experiments.id = $exp_id AND
        stages.stage_type <> 'meltcurve'
;

-- amplification, fluorescence
SELECT step_id, fluorescence_value, well_num, cycle_num, channel
    FROM fluorescence_data
    WHERE experiment_id = $exp_id
;


-- meltcurve, 2 queries: calibration query and ...
-- $exp_id is the experiment_id for the melt curve experiment, $stage_id is stage_id.
-- meltcrv.jl
SELECT well_num, temperature, fluorescence_value, channel
    FROM melt_curve_data
    WHERE
        experiment_id = $exp_id AND
        stage_id = $stage_id
;


-- analyze, depending on GUID
-- $exp_id is the experiment_id for the analyze experiment

-- thermal_performance_diagnostic, 1 query
-- analyze_customized/thermal_performance_diagnostic.jl
SELECT * FROM temperature_logs WHERE experiment_id = $exp_id

-- optical_test_single_channel, 1 query
-- analyze_customized/optical_test_single_channel.jl
SELECT step_id, fluorescence_value, well_num, cycle_num
    FROM fluorescence_data
    WHERE experiment_id = $exp_id
;

-- optical_test_dual_channel, 1 query
-- analyze_customized/optical_test_dual_channel.jl
SELECT step_id, fluorescence_value, well_num, cycle_num, channel
    FROM fluorescence_data
    WHERE experiment_id = $exp_id
;

-- optical_cal, 1 query
-- analyze_customized/optical_cal.jl, adj_w2wvaf.jl, calib.jl
SELECT step_id, fluorescence_value, well_num, cycle_num, channel
    FROM fluorescence_data
    WHERE experiment_id = $exp_id
;

-- thermal_consistency, 2 queries: calibration query and ...
-- $stage_id is probably 4.
-- analyze_customized/thermal_consistency.jl
SELECT well_num, temperature, fluorescence_value, channel
    FROM melt_curve_data
    WHERE
        experiment_id = $exp_id AND
        stage_id = $stage_id
;




--
