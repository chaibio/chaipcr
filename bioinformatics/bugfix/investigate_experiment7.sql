USE chaipcr;

-- calibration
SELECT experiments.id, completion_status, analyze_status, calibration_id, guid,
    steps.stage_id, stages.stage_type, steps.id, steps.name
FROM experiments 
    LEFT JOIN experiment_definitions
        ON experiments.experiment_definition_id = experiment_definitions.id 
    LEFT JOIN protocols
        ON experiment_definitions.id = protocols.experiment_definition_id
    LEFT JOIN stages
        ON stages.protocol_id = protocols.id
    LEFT JOIN steps
        ON stages.id = steps.stage_id
WHERE experiments.id = 6 ;

-- +----+-------------------+----------------+----------------+-----------------------------+----------+------------+------+------------+
-- | id | completion_status | analyze_status | calibration_id | guid                        | stage_id | stage_type | id   | name       |
-- +----+-------------------+----------------+----------------+-----------------------------+----------+------------+------+------------+
-- |  6 | success           | NULL           |              1 | dual_channel_optical_cal_v2 |        8 | holding    |   26 | Warm Up 75 |
-- |  6 | success           | NULL           |              1 | dual_channel_optical_cal_v2 |        8 | holding    |   27 | Warm Water |
-- |  6 | success           | NULL           |              1 | dual_channel_optical_cal_v2 |        8 | holding    |   28 | Water      |
-- |  6 | success           | NULL           |              1 | dual_channel_optical_cal_v2 |        8 | holding    |   29 | Swap       |
-- |  6 | success           | NULL           |              1 | dual_channel_optical_cal_v2 |        8 | holding    |   30 | Warm FAM   |
-- |  6 | success           | NULL           |              1 | dual_channel_optical_cal_v2 |        8 | holding    |   31 | FAM        |
-- |  6 | success           | NULL           |              1 | dual_channel_optical_cal_v2 |        8 | holding    |   32 | Swap       |
-- |  6 | success           | NULL           |              1 | dual_channel_optical_cal_v2 |        8 | holding    |   33 | Warm HEX   |
-- |  6 | success           | NULL           |              1 | dual_channel_optical_cal_v2 |        8 | holding    |   34 | HEX        |
-- +----+-------------------+----------------+----------------+-----------------------------+----------+------------+------+------------+

-- water
SELECT fluorescence_value, well_num, channel
    FROM fluorescence_data
WHERE experiment_id = 6 AND step_id = 28
ORDER BY channel, well_num ;

-- +--------------------+----------+---------+
-- | fluorescence_value | well_num | channel |
-- +--------------------+----------+---------+
-- |              17275 |        0 |       1 |
-- |              19833 |        1 |       1 |
-- |              19578 |        2 |       1 |
-- |              20563 |        3 |       1 |
-- |              12187 |        4 |       1 |
-- |              18485 |        5 |       1 |
-- |              19543 |        6 |       1 |
-- |              19261 |        7 |       1 |
-- |              12510 |        8 |       1 |
-- |              10805 |        9 |       1 |
-- |              15503 |       10 |       1 |
-- |              13138 |       11 |       1 |
-- |              12808 |       12 |       1 |
-- |              10954 |       13 |       1 |
-- |              13537 |       14 |       1 |
-- |              10570 |       15 |       1 |
-- |               1992 |        0 |       2 |
-- |               1981 |        1 |       2 |
-- |               2040 |        2 |       2 |
-- |               1949 |        3 |       2 |
-- |               1714 |        4 |       2 |
-- |               2294 |        5 |       2 |
-- |               1857 |        6 |       2 |
-- |               1851 |        7 |       2 |
-- |               2005 |        8 |       2 |
-- |               2134 |        9 |       2 |
-- |               2140 |       10 |       2 |
-- |               2072 |       11 |       2 |
-- |               2044 |       12 |       2 |
-- |               1969 |       13 |       2 |
-- |               1947 |       14 |       2 |
-- |               2177 |       15 |       2 |
-- +--------------------+----------+---------+

-- FAM
SELECT fluorescence_value, well_num, channel
    FROM fluorescence_data
WHERE experiment_id = 6 AND step_id = 31
ORDER BY channel, well_num ;

-- +--------------------+----------+---------+
-- | fluorescence_value | well_num | channel |
-- +--------------------+----------+---------+
-- |              16773 |        0 |       1 |
-- |              19277 |        1 |       1 |
-- |              19102 |        2 |       1 |
-- |              20176 |        3 |       1 |
-- |              11883 |        4 |       1 |
-- |              17952 |        5 |       1 |
-- |              18918 |        6 |       1 |
-- |              18775 |        7 |       1 |
-- |              12217 |        8 |       1 |
-- |              10515 |        9 |       1 |
-- |              15195 |       10 |       1 |
-- |              12931 |       11 |       1 |
-- |              12587 |       12 |       1 |
-- |              10748 |       13 |       1 |
-- |              13276 |       14 |       1 |
-- |              10373 |       15 |       1 |
-- |               2000 |        0 |       2 |
-- |               1975 |        1 |       2 |
-- |               2050 |        2 |       2 |
-- |               1957 |        3 |       2 |
-- |               1713 |        4 |       2 |
-- |               2276 |        5 |       2 |
-- |               1863 |        6 |       2 |
-- |               1867 |        7 |       2 |
-- |               2022 |        8 |       2 |
-- |               2125 |        9 |       2 |
-- |               2157 |       10 |       2 |
-- |               2073 |       11 |       2 |
-- |               2049 |       12 |       2 |
-- |               1978 |       13 |       2 |
-- |               1959 |       14 |       2 |
-- |               2169 |       15 |       2 |
-- +--------------------+----------+---------+

-- HEX
SELECT fluorescence_value, well_num, channel
    FROM fluorescence_data
WHERE experiment_id = 6 AND step_id = 34
ORDER BY channel, well_num ;

-- +--------------------+----------+---------+
-- | fluorescence_value | well_num | channel |
-- +--------------------+----------+---------+
-- |              16367 |        0 |       1 |
-- |              18894 |        1 |       1 |
-- |              18793 |        2 |       1 |
-- |              19974 |        3 |       1 |
-- |              11747 |        4 |       1 |
-- |              17652 |        5 |       1 |
-- |              18540 |        6 |       1 |
-- |              18447 |        7 |       1 |
-- |              12052 |        8 |       1 |
-- |              10342 |        9 |       1 |
-- |              15020 |       10 |       1 |
-- |              12831 |       11 |       1 |
-- |              12448 |       12 |       1 |
-- |              10577 |       13 |       1 |
-- |              13062 |       14 |       1 |
-- |              10236 |       15 |       1 |
-- |               1995 |        0 |       2 |
-- |               1958 |        1 |       2 |
-- |               2054 |        2 |       2 |
-- |               1961 |        3 |       2 |
-- |               1714 |        4 |       2 |
-- |               2287 |        5 |       2 |
-- |               1863 |        6 |       2 |
-- |               1869 |        7 |       2 |
-- |               2020 |        8 |       2 |
-- |               2109 |        9 |       2 |
-- |               2148 |       10 |       2 |
-- |               2071 |       11 |       2 |
-- |               2033 |       12 |       2 |
-- |               1959 |       13 |       2 |
-- |               1946 |       14 |       2 |
-- |               2184 |       15 |       2 |
-- +--------------------+----------+---------+

SELECT experiments.id, completion_status, analyze_status, calibration_id, guid,
    steps.stage_id, stages.stage_type, steps.id, steps.name
FROM experiments 
    LEFT JOIN experiment_definitions
        ON experiments.experiment_definition_id = experiment_definitions.id
    LEFT JOIN protocols
        ON experiment_definitions.id = protocols.experiment_definition_id
    LEFT JOIN stages
        ON stages.protocol_id = protocols.id
    LEFT JOIN steps
        ON stages.id = steps.stage_id
WHERE experiments.id = 7 ;

-- +----+-------------------+----------------+----------------+------+----------+------------+------+------+
-- | id | completion_status | analyze_status | calibration_id | guid | stage_id | stage_type | id   | name |
-- +----+-------------------+----------------+----------------+------+----------+------------+------+------+
-- |  7 | success           | NULL           |              6 | NULL |       13 | meltcurve  |   41 | NULL |
-- |  7 | success           | NULL           |              6 | NULL |       13 | meltcurve  |   42 | NULL |
-- |  7 | success           | NULL           |              6 | NULL |       13 | meltcurve  |   43 | NULL |
-- +----+-------------------+----------------+----------------+------+----------+------------+------+------+

SELECT experiments.id, completion_status, analyze_status, calibration_id, guid,
    steps.stage_id, stages.stage_type, steps.id, steps.name
FROM experiments 
    LEFT JOIN experiment_definitions
        ON experiments.experiment_definition_id = experiment_definitions.id 
    LEFT JOIN protocols
        ON experiment_definitions.id = protocols.experiment_definition_id
    LEFT JOIN stages
        ON stages.protocol_id = protocols.id
    LEFT JOIN steps
        ON stages.id = steps.stage_id
WHERE experiments.id = 8 ;

-- +----+-------------------+----------------+----------------+------+----------+------------+------+--------------------+
-- | id | completion_status | analyze_status | calibration_id | guid | stage_id | stage_type | id   | name               |
-- +----+-------------------+----------------+----------------+------+----------+------------+------+--------------------+
-- |  8 | success           | NULL           |              6 | NULL |       14 | holding    |   44 | Initial Denaturing |
-- |  8 | success           | NULL           |              6 | NULL |       15 | cycling    |   45 | Denature           |
-- |  8 | success           | NULL           |              6 | NULL |       15 | cycling    |   46 | Anneal             |
-- +----+-------------------+----------------+----------------+------+----------+------------+------+--------------------+