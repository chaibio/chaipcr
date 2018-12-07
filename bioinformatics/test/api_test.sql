# api_test.sql
#
# Author: Tom Price
# Date: Dec 2018
#
# obtain data from test database 20180907_juliatestdb.sql
# to test Julia API

# 1. Dual channel amplification request test
#
# Calibration (Water, channel_1, channel_2) data comes from the following sql query: 
# 
# SELECT fluorescence_value, well_num, channel
#     FROM fluorescence_data
#     WHERE experiment_id = $calib_id AND step_id = $step_id
#     ORDER BY channel, well_num
# ;
#
# Raw Data comes from the following sql query: 
#
# SELECT fluorescence_value, well_num, cycle_num, channel
#     FROM fluorescence_data
#     WHERE experiment_id = $exp_id AND step_id = $step_id
#   ORDER BY channel, well_num, cycle_num
# ;
#
# other parameters passed to Julia are:
#
# min_reliable_cyc
# baseline_cyc_bounds
# baseline_method
# cq_method
# min_fluomax
# min_D1max
# min_D2max
#
# Let's try 135 as the calibration experiment and 136 as the test experiment
SET @calib_id = 135;
SET @exp_id = 136;

# Look at step_id's in the calibration experiment
SELECT step_id, channel, well_num
	FROM fluorescence_data
	WHERE experiment_id = @calib_id
	ORDER BY step_id, channel, well_num
;

# Let's assume step_id=28 is the water condition,
# step_id=31 means "channel 1", and step_id=34 means "channel 2".
# There are 2 channels (1-2) with 16 wells each (0-15).
SET @step_id = 34;
SELECT step_id, channel, well_num, count(*)
	FROM fluorescence_data
	WHERE experiment_id = @calib_id
	GROUP BY step_id, channel, well_num
;

# Now let's look at experiment 136
# 2 channels * 16 wells * 40 cycles (0-39), 1 step
SELECT step_id, channel, well_num, cycle_num
	FROM fluorescence_data
	WHERE experiment_id = @exp_id
	ORDER BY step_id, channel, well_num, cycle_num
;

# Shell script

# Export calibration data
mysql -u root -B -e "
USE chaipcr ; \
SELECT fluorescence_value, step_id, channel, well_num \
FROM fluorescence_data \
WHERE experiment_id = 135 \
ORDER BY step_id, channel, well_num ;" > /mnt/share/calib_135.tsv

# Export raw data as JSON
mysql -u root -B -e "
USE chaipcr ; \
SELECT fluorescence_value, channel, well_num, cycle_num \
FROM fluorescence_data \
WHERE experiment_id = 136 \
ORDER BY channel, well_num, cycle_num ;" > /mnt/share/amp_136.tsv