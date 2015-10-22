# amp_cal

# load libraries
library(plyr)
library(qpcR)
library(reshape2)
library(RMySQL)


# function: set global constants using `<<-`
set_global <- function(num_wells=16, scaling_factor=9e5) {
    num_wells <<- num_wells
    scaling_factor <<- scaling_factor
    message('user-defined number of wells: ', num_wells)
    message('scaling factor for water calibration: ', scaling_factor)
    
    return(NULL)
    }


# function: load MySQL database and process data


# function: get data from MySQL database and perform calibration 
get_data_calib <- function(db_usr, db_pwd, db_host, db_port, db_name, # for connecting to MySQL database
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
    message('stage_id: ', stg_id)
    message('calibration_id: ', calib_id)
    
    # get fluorescence data for amplification
    fluo_qry <- sprintf('SELECT step_id, fluorescence_value, well_num, cycle_num, ramp_id 
                            FROM fluorescence_data 
                            LEFT JOIN ramps ON fluorescence_data.ramp_id = ramps.id
                            INNER JOIN steps ON fluorescence_data.step_id = steps.id OR steps.id = ramps.next_step_id 
                            WHERE fluorescence_data.experiment_id=%d AND steps.stage_id=%d 
                            ORDER BY well_num, cycle_num',
                            exp_id, stg_id)
    fluo_sel <- dbGetQuery(db_conn, fluo_qry)
    
    # cast fluo_sel into a pivot table organized by cycle_num (row label) and well_num (column label), average the data from all the available steps/ramps for each well and cycle
    fluo_melt <- melt(fluo_sel, id.vars=c('step_id', 'well_num', 'cycle_num', 'ramp_id'), 
                      measure.vars='fluorescence_value')
    fluo_cast <- dcast(fluo_melt, cycle_num ~ well_num, mean)
    
    
    # get calibration data
    
    calib_water_qry <-  sprintf('SELECT fluorescence_value, well_num 
                                    FROM fluorescence_data 
                                    WHERE experiment_id=%d AND step_id=2 
                                    ORDER BY well_num', 
                                    calib_id)
    calib_water <- dbGetQuery(db_conn, calib_water_qry)
    calib_water_fluo <- t(calib_water[,'fluorescence_value'])
    
    calib_signal_qry <- sprintf('SELECT fluorescence_value, well_num 
                                    FROM fluorescence_data 
                                    WHERE experiment_id=%d AND step_id=4 
                                    ORDER BY well_num', 
                                    calib_id)
    calib_signal <- dbGetQuery(db_conn, calib_signal_qry)
    calib_signal_fluo <- t(calib_signal[,'fluorescence_value'])
    
    if (!(all(dim(calib_water) == dim(calib_signal)))) {
        stop('dimensions not equal between calib_water and calib_signal') }
    
    num_calibd_wells <- dim(calib_water)[1]
    if (!(num_calibd_wells == num_wells)) {
        stop('number of calibrated wells is not equal to user-defined number of wells') }
    
    
    # perform calibration
    fluo_calib <- adply(fluo_cast, .margins=1, 
                        function(row1) scaling_factor
                                           * (row1[,as.character(0:(num_calibd_wells-1))] - calib_water_fluo) 
                                           / (calib_signal_fluo - calib_water_fluo)) # column 'cycle_num' will be automatically retained

    return(fluo_calib)
    }


# function: baseline subtraction and Ct
baseline_ct <- function(fluo_calib, 
                        model, baseline, basecyc, # modlist parameters
                        type, cp, # getPar parameters
                        ...) {
    fitted_curves <- modlist(fluo_calib, model=model, baseline=baseline, basecyc=basecyc)
    ct_eff <- getPar(fitted_curves, type=type, cp=cp)
    return(ct_eff)
    }




# workflow


# user inputs

# set_global
num_wells <- 16
scaling_factor <- 9e5

# get_data_calib
db_usr <- 'usr0'
db_pwd <- '0rsu'
db_host <- 'localhost'
db_port <- 3306
db_name <- 'josh1' # used: 'jyothi_data', 'josh'
# option 1
exp_id <- 10
stg_id <- 19
calib_id <- 9
# option 2
exp_id <- 23
stg_id <- 42
calib_id <- 9


# baseline_ct
model <- l4
baseline <- 'lin'
basecyc <- 1:5
type <- 'curve'
cp <- 'cpD2'


# standard operations
set_global(num_wells, scaling_factor)
fluo_calib <- get_data_calib(db_usr, db_pwd, db_host, db_port, db_name,
                             exp_id, stage_id, calib_id) 
ct_eff <- baseline_ct(fluo_calib, model, baseline, basecyc, type, cp)




