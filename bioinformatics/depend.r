# load dependencies

# Assumptions. (1) Data from every channel present in the data table should be used; i.e. if a channel is not used to collect data, it should be absent in the data table. (2) Names of `oc_signal_step_ids` are the same as names of calib_id[['signal']] and as channels present in the signal data of the calibration experiment.

# load libraries
library(jsonlite)
library(plyr)
#library(qpcR)
library(reshape2)
library(RMySQL)


# load dependencies from qpcR but not the whole package

library(MASS)
library(minpack.lm)
#library(rgl)
library(robustbase)
library(Matrix)
library(DBI)

#setwd(Sys.getenv('RWORKDIR')) # Xia Hong

scripts <- list.files(pattern='\\.[Rr]$', recursive=TRUE)
scripts <- scripts[scripts != 'depend.r']
for (script in scripts) source(script) # recursively load all the files that ends with '.R' or '.r'

data_fns <- list.files(pattern='\\.(rda)|(RData)$', recursive=TRUE)
for (data_fn in data_fns) load(data_fn)


# set constants

# num_wells <- 16

scaling_factor_optic_calib <- 3.7 # used: 9e5, 1e5, 1.2e6, 3
scaling_factors_deconv <- c('1'=1, '2'=5.6) # used: c('1'=1, '2'=1, 2, 3.5, 8, 7, 5.6)


# function: connect to MySQL database; message about data selection
db_etc <- function(db_usr, db_pwd, db_host, db_port, db_name, # for connecting to MySQL database
                   exp_id, stage_id, calib_id # for selecting data to analyze
                   ) {
    
    message('db: ', db_name)
    db_conn <- dbConnect(RMySQL::MySQL(), 
                         user=db_usr, 
                         password=db_pwd, 
                         host=db_host, 
                         port=db_port, 
                         dbname=db_name)
    
    message('experiment_id: ', exp_id)
    message('stage_id: ', stage_id)
    message('calibration_id: ', calib_id)
    
    return(db_conn)
    }


