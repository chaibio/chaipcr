# load dependencies for 'amp.r' and 'meltcrv.r'


# load libraries
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

dpds <- dir(pattern='\\.[Rr]$', recursive=TRUE)
dpds <- dpds[dpds != 'depend.r']
dummy <- lapply(dpds, source) # recursively load all the files that ends with '.R' or '.r'

load('qpcR/sysdata.rda')
load('k.RData') # load hard-coded deconvolution matrix


# set constants

num_wells <<- 16
scaling_factors <<- c('1'=1e5, '2'=2e5)


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


