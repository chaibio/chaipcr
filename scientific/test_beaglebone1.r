# test_beaglebone1


# load dependencies from qpcR but not the whole package

setwd('/root/xqrm/qpcR') # beaglebone

library(MASS)
library(minpack.lm)
#library(rgl)
library(robustbase)
library(Matrix)
library(DBI)

qpcR_funcs <- c('Cy0.R', 'eff.R', 'efficiency.R', 'expfit.R', 'getPar.r', 'KOD.r', 'midpoint.R', 'modlist.r', 'pcrfit.r', 'replist.r', 'resVar.R', 'RMSE.R', 'sliwin.R', 'takeoff.R', 'utils.R')
dummy <- lapply(qpcR_funcs, source)

load('sysdata.rda')


# workflow

source('/root/xqrm/amp_cal.r')


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
# stg_id <- 19
# calib_id <- 9
# option 2
exp_id <- 23
stg_id <- 42
calib_id <- 9


# baseline_ct
model <- l4
baselin <- 'lin'
basecyc <- 1:5
type <- 'curve'
cp <- 'cpD2'


# use functions
fluo_calib <- get_data_calib(db_usr, db_pwd, db_host, db_port, db_name,
                             exp_id, stage_id, calib_id,
                             show_running_time) # 1.63-1.75 sec (1st time, 3 tests); 0.94-1.60 sec (2nd time and on, 5 tests)
fc_ct <- baseline_ct(fluo_calib, model, baselin, basecyc, type, cp, show_running_time)
# qpcR package: 4.76-5.29 sec (4 tests)
# qpcR functions: 3.20-3.73 sec (6 tests)
