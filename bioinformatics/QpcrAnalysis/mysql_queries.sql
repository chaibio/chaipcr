

-- MySQL queries for data as input to Julia
--
-- It'll be best if Rails code is designed to easily accommodate changes to these queries in future.
-- Assuming: before Rails passes data to Julia as JSON, it converted the table returned by SQL query
-- into an associative of name-value pairs, where each pair represents a column in the table,
-- i.e. name is the column header (e.g. "step_id"), value is a vector of the data (e.g. [1,1,2,2,2,3])

/*
e.g.
This table below
step_id well_num
      1        1
      1        2
      2        3
      2        4
      2        5
      3        6
is converted to...
JSON {"step_id":[1,1,2,2,2,3],"well_num":[1,2,3,4,5,6]}
*/

-- it can be easily converted to data frame in Julia via `DataFrame(JSON.parse("some_json_in_aforementioned_format"))`


-- queries depend on action


-- calibration, 1 query. needed for:
--       amplification
--       meltcurve
--       analyze optical_cal
--       analyze optical_test_dual_channel
--       analyze thermal_consistency
--
-- keys (each key represent a step): for all actions - water, channel_1, channel_2; 
-- extra key only for analyze optical_test_dual_channel - baseline.
-- analyze_customized/optical_cal.jl, adj_w2wvaf.jl, calib.jl
SELECT fluorescence_value, well_num, channel
    FROM fluorescence_data
    WHERE experiment_id = $calib_id AND step_id = $step_id
	ORDER BY channel, well_num
;
/*
JSON format

single channel
{"calibration_info":{
    "water":[
        [xx,xx,xx,xx],
        null
    ],
    "channel_1":[
        [xx,xx,xx,xx],
        null
    ]
}}

dual channel. 1st vector for fluorescence from channel 1, 2nd for 2.
{"calibration_info":{
    "water":[
        [xx,xx,xx,xx],
        [xx,xx,xx,xx]
    ],
    "channel_1":[
        [xx,xx,xx,xx],
        [xx,xx,xx,xx]
    ],
    "channel_2":[
        [xx,xx,xx,xx],
        [xx,xx,xx,xx]
    ],
}}
*/


-- amplification, 3 queries: calibration query and ...
-- $exp_id is the experiment_id for the amplification experiment
-- amp.jl

-- amplification, fluorescence
SELECT fluorescence_value, well_num, cycle_num, channel
    FROM fluorescence_data
    WHERE experiment_id = $exp_id AND step_id = $step_id
	ORDER BY channel, well_num, cycle_num
;


-- meltcurve, 2 queries: calibration query and ...
-- $exp_id is the experiment_id for the melt curve experiment, $stage_id is stage_id.
-- meltcrv.jl
SELECT well_num, temperature, fluorescence_value, channel
    FROM melt_curve_data
    WHERE
        experiment_id = $exp_id AND
        stage_id = $stage_id
	ORDER BY channel, well_num, temperature
;


-- analyze, depending on GUID
-- $exp_id is the experiment_id for the analyze experiment

-- thermal_performance_diagnostic, 1 query
-- analyze_customized/thermal_performance_diagnostic.jl
SELECT *
    FROM temperature_logs
    WHERE experiment_id = $exp_id
    ORDER BY elapsed_time
;

-- optical_test_single_channel, 1 query
-- analyze_customized/optical_test_single_channel.jl
SELECT step_id, fluorescence_value, well_num, cycle_num
    FROM fluorescence_data
    WHERE experiment_id = $exp_id
	ORDER BY step_id, well_num, cycle_num
;

-- optical_test_dual_channel, 1 query
-- analyze_customized/optical_test_dual_channel.jl
-- see calibration query

-- optical_cal, 1 query
-- analyze_customized/optical_cal.jl, adj_w2wvaf.jl, calib.jl
-- see calibration query

-- thermal_consistency, 2 queries: calibration query and ...
-- $stage_id is probably 4.
-- analyze_customized/thermal_consistency.jl
SELECT well_num, temperature, fluorescence_value, channel
    FROM melt_curve_data
    WHERE
        experiment_id = $exp_id AND
        stage_id = $stage_id
	ORDER BY channel, well_num, temperature
;




--
