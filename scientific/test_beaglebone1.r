# test_beaglebone1


Sys.setenv('RWORKDIR'='/root/xqrm') # beaglebone


# workflow

source('amp_cal.r')


# user inputs

show_running_time <- TRUE # whether to show time cost for running each function

# get_data_calib
db_usr <- 'root'
db_pwd <- ''
db_host <- 'localhost'
db_port <- 3306
db_name <- 'xqrm_josh1' # used: 'xqrm_jyothi', 'xqrm_josh1'
# # option 1
# exp_id <- 10
# stage_id <- 19
# calib_id <- 9
# option 2
exp_id <- 23
stage_id <- 42
calib_id <- 9


# baseline_ct
model <- l4
baselin <- 'parm' # used: 'none', 'mean', 'median', 'lin', 'quad', 'parm'
basecyc <- 1:5
fallback <- 'lin'
type <- 'curve'
cp <- 'cpD2'


# use functions
fluo_calib <- get_data_calib(db_usr, db_pwd, db_host, db_port, db_name,
                             exp_id, stage_id, calib_id,
                             show_running_time) # 1.63-1.75 sec (1st time, 3 tests); 0.94-1.60 sec (2nd time and on, 5 tests)
fc_ct <- baseline_ct(fluo_calib, model, baselin, basecyc, fallback, type, cp, show_running_time)
# qpcR package: 4.76-5.29 sec (4 tests)
# qpcR functions: 3.20-3.73 sec (6 tests)
