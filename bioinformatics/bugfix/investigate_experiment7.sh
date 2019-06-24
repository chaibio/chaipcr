#!/usr/bin/bash

# chaipcr calibration: Water
# experiments.id = 6
# stages.id = 8
# stages.stage_type = holding
# fluorescence_data.step_id = 28
mysql -u root -B -e "
USE chaipcr;
SELECT fluorescence_value, well_num, channel
FROM fluorescence_data
WHERE experiment_id = 6 AND step_id = 28
ORDER BY channel, well_num ;" | tail -n+2 | cut -f1 | awk 'BEGIN {RS="";FS=" "}{gsub(/\n/,",")}{print}' -

# chaipcr calibration: FAM
# experiments.id = 6
# stages.id = 8
# stages.stage_type = holding
# fluorescence_data.step_id = 31
mysql -u root -B -e "
USE chaipcr;
SELECT fluorescence_value, well_num, channel
FROM fluorescence_data
WHERE experiment_id = 6 AND step_id = 31
ORDER BY channel, well_num ;" | tail -n+2 | cut -f1 | awk 'BEGIN {RS="";FS=" "}{gsub(/\n/,",")}{print}' -

# chaipcr calibration: HEX
# experiments.id = 6
# stages.id = 8
# stages.stage_type = holding
# fluorescence_data.step_id = 34
mysql -u root -B -e "
USE chaipcr;
SELECT fluorescence_value, well_num, channel
FROM fluorescence_data
WHERE experiment_id = 6 AND step_id = 31
ORDER BY channel, well_num ;" | tail -n+2 | cut -f1 | awk 'BEGIN {RS="";FS=" "}{gsub(/\n/,",")}{print}' -




# chaipcr experiment 7 dual channel meltcurve data
# experiments.id = 7
# stages.id = 13
# stages.stage_type = meltcurve
mysql -u root -B -e "USE chaipcr ;
SELECT fluorescence_value, temperature, well_num, channel
FROM melt_curve_data
WHERE experiment_id = 7 AND stage_id = 13
ORDER BY channel, well_num ;" > mc_7.tsv




# chaipcr experiment 8 dual channel amplification data
# experiments.id = 8
# stages.id = 13
# stages.stage_type = meltcurve
mysql -u root -B -e "USE chaipcr ;
SELECT fluorescence_value, well_num, cycle_num, channel
FROM fluorescence_data
WHERE experiment_id = 8 AND stage_id = 15
ORDER BY channel, well_num, cycle_num ;" > amp_8.tsv
