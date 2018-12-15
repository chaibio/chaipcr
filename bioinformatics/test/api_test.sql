# api_test.sql
#
# Author: Tom Price
# Date: Dec 2018
#
# obtain data from test database 20180907_juliatestdb.sql
# to test Julia API

import JSON
import DataStructures.OrderedDict

# Browse experiments
SELECT
id AS exp_id,
experiment_definition_id AS def_id,
calibration_id AS calib_id,
analyze_status AS analyzed,
cached_temperature AS temp,
power_cycles,
name
FROM experiments
WHERE completion_status="success"
AND time_valid="1" ;





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

# Export calibration data (135)
mysql -u root -B -e "
USE chaipcr ; \
SELECT fluorescence_value, step_id, channel, well_num \
FROM fluorescence_data \
WHERE experiment_id = 135 \
ORDER BY step_id, channel, well_num ;" > calib_135.tsv

# Export experimental data (136)
mysql -u root -B -e "
USE chaipcr ; \
SELECT fluorescence_value, channel, well_num, cycle_num \
FROM fluorescence_data \
WHERE experiment_id = 136 \
ORDER BY channel, well_num, cycle_num ;" > amp_136.tsv



# Test_1ch and Test_2ch: Match experiments to stages
USE test_1ch ;
SELECT experiments.id, stages.id, stages.stage_type
FROM experiments
LEFT JOIN protocols ON experiments.experiment_definition_id = protocols.experiment_definition_id
LEFT JOIN stages ON protocols.id = stages.protocol_id
WHERE experiments.id = @exp_id AND stages.stage_type <> 'holding' ;

# Test_1ch and Test_2ch: Match experiment_id to step_id
USE test_1ch ;
SELECT experiment_id, channel, well_num, step_id, COUNT(*)
FROM fluorescence_data
WHERE experiment_id = @exp_id
GROUP BY experiment_id, channel, well_num, step_id ;






# Test_1ch calibration: Water
# experiments.id = 168
# stages.id = 1
# stages.stage_type = holding
# fluorescence_data.step_id = 2
mysql -u root -B -e "
USE test_1ch;
SELECT fluorescence_value, well_num, channel
FROM fluorescence_data
WHERE experiment_id = 168 AND step_id = 2
ORDER BY channel, well_num ;" | tail -n+2 | cut -f1 | awk 'BEGIN {RS="";FS=" "}{gsub(/\n/,",")}{print}' -

# Test_1ch calibration: Signal
# experiments.id = 168
# stages.id = 1
# stages.stage_type = holding
# fluorescence_data.step_id = 4
mysql -u root -B -e "
USE test_1ch;
SELECT fluorescence_value, well_num, channel
FROM fluorescence_data
WHERE experiment_id = 168 AND step_id = 4
ORDER BY channel, well_num ;" | tail -n+2 | cut -f1 | awk 'BEGIN {RS="";FS=" "}{gsub(/\n/,",")}{print}' -

water_cal_1=
    [20351,13854,16950,18614,19292,21191,19613,21150,21611,17390,21328,23590,24131,20167,19417,25120];
signal_cal_1=
    [2037915,2030879,2356324,2286590,2578814,2660975,2390835,2290655,2419225,2240444,2734095,3069099,
2599044,2354805,2267721,2879192];

calib_1=OrderedDict(
    "water"     => Dict("fluorescence_value" => [water_cal_1,  nothing]),
    "channel_1" => Dict("fluorescence_value" => [signal_cal_1, nothing])
)




# Test_2ch calibration: Water
# experiments.id = 219
# stages.id = 226
# stages.stage_type = holding
# fluorescence_data.step_id = 325
mysql -u root -B -e "
USE test_2ch;
SELECT fluorescence_value, well_num, channel
FROM fluorescence_data
WHERE experiment_id = 219 AND step_id = 325
ORDER BY channel, well_num ;" | tail -n+2 | cut -f1 | awk 'BEGIN {RS="";FS=" "}{gsub(/\n/,",")}{print}' -

# Test_2ch calibration: Channel 1
# experiments.id = 219
# stages.id = 226
# stages.stage_type = holding
# fluorescence_data.step_id = 327
mysql -u root -B -e "
USE test_2ch;
SELECT fluorescence_value, well_num, channel
FROM fluorescence_data
WHERE experiment_id = 219 AND step_id = 327
ORDER BY channel, well_num ;" | tail -n+2 | cut -f1 | awk 'BEGIN {RS="";FS=" "}{gsub(/\n/,",")}{print}' -

# Test_2ch calibration: Channel 2
# experiments.id = 219
# stages.id = 226
# stages.stage_type = holding
# fluorescence_data.step_id = 329
mysql -u root -B -e "
USE test_2ch;
SELECT fluorescence_value, well_num, channel
FROM fluorescence_data
WHERE experiment_id = 219 AND step_id = 329
ORDER BY channel, well_num ;" | tail -n+2 | cut -f1 | awk 'BEGIN {RS="";FS=" "}{gsub(/\n/,",")}{print}' -

cal_water_2=[
        [12095,20829,14218,19162,14613,12937,12487,14240,7543,14187,12778,12404,13275,18710,10472,8520],
        [ 2163, 2058, 2216, 1869, 1890, 2246, 1997, 2104,2287, 1981, 2120, 3471, 1953, 2018, 1956,2196]
    ]
cal_FAM_2=[
        [79676,104728,95264,90512,109013,103317,92905,100809,82292,115539,93250,106691,113931,134691,78968,80789],
        [35683, 41892,39971,40173, 43931, 44413,43240, 42156,39951, 44385,40652, 40888, 45433, 47371,42637,43064]
    ]
    cal_HEX_2=[
        [14622,21383,15831,21415,18148,16878,15657,17881,11466,17953,16429,15830,17765,22733,14600,12180],
        [41396,48051,45444,44977,50132,51689,49093,47231,43050,49144,44858,43502,48565,47037,48413,47160]
    ]

calib_2=OrderedDict(
    "water"     => Dict("fluorescence_value" => cal_water_2),
    "channel_1" => Dict("fluorescence_value" => cal_FAM_2),
    "channel_2" => Dict("fluorescence_value" => cal_HEX_2)
)




# Test_1ch amplification: Raw data
# experiments.id = 169
# stages.id = 216
# stages.stage_type = cycling
# fluorescence_data.step_id = 400
mysql -u root -B -e "
USE test_1ch;
SELECT fluorescence_value, well_num, cycle_num, channel
FROM fluorescence_data
WHERE experiment_id = 169 AND step_id = 400
ORDER BY channel, well_num, cycle_num ;" > amp_169.tsv

amp_169=readdlm("amp_169.tsv",'\t',header=true)
raw_amp_1=OrderedDict(
    amp_169[2][1]    => amp_169[1][:,1],
    amp_169[2][2]    => Vector{Integer}(amp_169[1][:,2]),
    amp_169[2][3]    => Vector{Integer}(amp_169[1][:,3]),
    amp_169[2][4]    => Vector{Integer}(amp_169[1][:,4])
)

amp_1=OrderedDict(
  "experiment_id"       => 169,
  "step_id"             => 400,
  "min_reliable_cyc"    => 5,
  "calibration_info"    => calib_1,
  "baseline_cyc_bounds" => Any[],
  "baseline_method"     => "sigmoid",
  "cq_method"           => "Cy0",
  "min_fluomax"         => 4356,
  "min_D1max"           => 472,
  "min_D2max"           => 41,
  "raw_data"            => raw_amp_1
)

open("test_1ch_amp_169.json","w") do f
    JSON.print(f, amp_1)
end




# Test_1ch meltcurve data
# experiments.id = 170
# stages.id = 219
# stages.stage_type = meltcurve
mysql -u root -B -e "USE test_1ch ;
SELECT fluorescence_value, temperature, well_num, channel
FROM melt_curve_data
WHERE experiment_id = 170 AND stage_id = 219
ORDER BY channel, well_num ;" > mc_170.tsv

mc_170=readdlm("mc_223.tsv",'\t',header=true)
raw_mc_1=OrderedDict(
    mc_170[2][1]    => mc_170[1][:,1],
    mc_170[2][2]    => mc_170[1][:,2],
    mc_170[2][3]    => Vector{Integer}(mc_170[1][:,3]),
    mc_170[2][4]    => Vector{Integer}(mc_170[1][:,4])
)

mc_1=OrderedDict(
    "experiment_id"       => 170,
    "stage_id"            => 219,
    "calibration_info"    => calib_1,
    "channel_nums"        => [1],
    "qt_prob"             => 0.64,
    "max_normd_qtv"       => 0.8,
    "top_N"               => 4,
    "raw_data"            => raw_mc_1
)

open("test_1ch_mc_170.json","w") do f
    JSON.print(f, mc_1)
end




# Test_2ch meltcurve data
# experiments.id = 223
# stages.id = 311
# stages.stage_type = meltcurve
mysql -u root -B -e "USE test_2ch ;
SELECT fluorescence_value, temperature, well_num, channel
FROM melt_curve_data
WHERE experiment_id = 223 AND stage_id = 311
ORDER BY channel, well_num ;" > mc_223.tsv

mc_223=readdlm("mc_223.tsv",'\t',header=true)
raw_mc_2=OrderedDict(
    mc_223[2][1]    => mc_223[1][:,1],
    mc_223[2][2]    => mc_223[1][:,2],
    mc_223[2][3]    => Vector{Integer}(mc_223[1][:,3]),
    mc_223[2][4]    => Vector{Integer}(mc_223[1][:,4])
)

mc_2=OrderedDict(
    "experiment_id"       => 223,
    "stage_id"            => 311,
    "calibration_info"    => calib_2,
    "channel_nums"        => [1,2],
    "qt_prob"             => 0.64,
    "max_normd_qtv"       => 0.8,
    "top_N"               => 4,
    "raw_data"            => raw_mc_2
)

open("test_2ch_mc_223.json","w") do f
    JSON.print(f, mc_2)
end




# Test_1ch thermal consistency single channel
# experiments.id = 146
# stages.id = 4
# stages.stage_type = meltcurve
mysql -u root -B -e "
USE test_1ch ;
SELECT fluorescence_value, temperature, well_num, channel
FROM melt_curve_data
WHERE experiment_id = 146 AND stage_id = 4
ORDER BY channel, well_num ;" > tc_146.tsv

tc_146=readdlm("tc_146.tsv",'\t',header=true)
raw_tc_1=OrderedDict(
    tc_146[2][1]    => tc_146[1][:,1],
    tc_146[2][2]    => tc_146[1][:,2],
    tc_146[2][3]    => Vector{Integer}(tc_146[1][:,3]),
    tc_146[2][4]    => Vector{Integer}(tc_146[1][:,4])
)

tc_1=OrderedDict(
    "experiment_id"       => 146,
    "stage_id"            => 4,
    "calibration_info"    => calib_1,
    "channel_nums"        => [1],
    "qt_prob"             => 0.64,
    "max_normd_qtv"       => 0.8,
    "top_N"               => 4,
    "raw_data"            => raw_tc_1
)

open("test_1ch_tc_146.json","w") do f
    JSON.print(f, tc_1)
end

    


# Test_1ch optical test single channel
# experiments.id = 161
# stages.id = 5
# stages.stage_type = holding
# step_id = 12 (baseline)
mysql -u root -B -e "
USE test_1ch ;
SELECT fluorescence_value, well_num
FROM fluorescence_data
WHERE experiment_id = 161
AND step_id = 12
AND cycle_num = 1
ORDER BY well_num"

# experiments.id = 161
# stages.id = 5
# stages.stage_type = holding
# step_id = 13 (excitation)
mysql -u root -B -e "
USE test_1ch ;
SELECT fluorescence_value, well_num
FROM fluorescence_data
WHERE experiment_id = 161
AND step_id = 13
AND cycle_num = 1
ORDER BY well_num"

baseline_ot_1 = [1704,1803,1522,1442,1490,1540,1834,1757,1593,1705,1711,1586,1529,1638,1659,1502]
excitation_ot_1=[45213,21030,23819,26412,25405,31761,27095,34442,41152,26695,30389,34168,37144,36466,37692,44756]

ot_1 = OrderedDict(
        "baseline" => OrderedDict(
                "fluorescence_value" => [ baseline_ot_1 ]
        ),
        "excitation" => OrderedDict(
                "fluorescence_value" => [ excitation_ot_1 ]
        )
)

open("test_1ch_ot_161.json","w") do f
    JSON.print(f, ot_1)
end




# Test_2ch optical test dual channel
# experiments.id = 190
# stages.id = 5
# stages.stage_type = holding
# step_ids = 116 (baseline), 117 (water), 119 (FAM/channel_1), 121 (HEX/channel_2)
mysql -u root -B -e "
USE test_2ch ;
SELECT fluorescence_value, channel, well_num
FROM fluorescence_data
WHERE experiment_id = 190
AND step_id = 116
AND cycle_num = 1
ORDER BY channel, well_num"

mysql -u root -B -e "
USE test_2ch ;
SELECT fluorescence_value, channel, well_num
FROM fluorescence_data
WHERE experiment_id = 190
AND step_id = 117
AND cycle_num = 1
ORDER BY channel, well_num"

mysql -u root -B -e "
USE test_2ch ;
SELECT fluorescence_value, channel, well_num
FROM fluorescence_data
WHERE experiment_id = 190
AND step_id = 119
AND cycle_num = 1
ORDER BY channel, well_num"

mysql -u root -B -e "
USE test_2ch ;
SELECT fluorescence_value, channel, well_num
FROM fluorescence_data
WHERE experiment_id = 190
AND step_id = 121
AND cycle_num = 1
ORDER BY channel, well_num"

ot_baseline_2=[563  506  559  542  515  531  540  590  480  563  542  571  599  567  519  571;
              1623 1585 1628 1619 1608 1614 1627 1661 1573 1654 1625 1651 1677 1628 1581 1632]
ot_water_2=[15477 19246 11922 18452 15154 11504 11059 13373  7701 20789 16486 13542 14345 18934  9841  8883;
             2739  1887  2194  1650  1800  2068  1813  1876  2205  2076  3899  4153  1914  1919  1723  2080]
ot_FAM_2=[15416 19313 11952 18554 15215 11440 10914 13236  7710 20775 16520 13540 14362 18873 10036  8803;
           2620  1919  2209  1701  1804  1993  1678  1836  2225  2054  3919  4141  1943  1821  1902  2007]
ot_HEX_2=[15438 19277 11992 18699 15215 11518 11005 13508  7650 20786 16532 13541 14324 19017  9784  8718;
           2616  1877  2212  1830  1771  2081  1754  2020  2149  1976  3914  4150  1929  1983  1709  1989]

ot_2 = OrderedDict(
    "baseline" => OrderedDict(
        "fluorescence_value" => transpose(ot_baseline_2)
    ),
    "water" => OrderedDict(
        "fluorescence_value" => transpose(ot_water_2)
    ),
    "channel_1" => OrderedDict(
        "fluorescence_value" => transpose(ot_FAM_2)
    ),
    "channel_2" => OrderedDict(
        "fluorescence_value" => transpose(ot_HEX_2)
    )
)
open("test_2ch_ot_190.json","w") do f
    JSON.print(f, ot_2)
end




mysql -u root -B -e "SELECT stages.id FROM experiments
LEFT JOIN protocols ON experiments.experiment_definition_id = protocols.experiment_definition_id
LEFT JOIN stages ON protocols.id = stages.protocol_id
WHERE experiments.id = 170 AND stages.stage_type <> 'holding'"

USE test_1ch ;
SELECT stages.id, stages.stage_type FROM experiments
LEFT JOIN protocols ON experiments.experiment_definition_id = protocols.experiment_definition_id
LEFT JOIN stages ON protocols.id = stages.protocol_id
WHERE experiments.id = 146 ;

USE test_1ch ;
SELECT channel, step_id, steps.name, COUNT(*) FROM fluorescence_data
WHERE experiment_id = 146
GROUP BY step_id, steps.name, channel ;

USE test_1ch ;
SELECT channel, well_num, COUNT(*)
FROM melt_curve_data
WHERE experiment_id = 146 AND stage_id = 4
GROUP BY channel, well_num ;
