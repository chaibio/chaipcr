# amp_cal

# load libraries
library(plyr)
#library(qpcR)
library(reshape2)
library(RMySQL)


num_wells <- 16
scaling_factor <- 9e5


# function: load MySQL database and process data


# function: get data from MySQL database and perform calibration 
get_data_calib <- function(db_usr, db_pwd, db_host, db_port, db_name, # for connecting to MySQL database
                           exp_id, stage_id, calib_id, # for selecting data to analyze
                           show_running_time=FALSE # option to show time cost to run this function
                           ) {
    
    # start counting for running time
    func_name <- 'get_data_calib'
    start_time <- proc.time()[['elapsed']]
    
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
    
    # report time cost for this function
    end_time <- proc.time()[['elapsed']]
    if (show_running_time) message('`', func_name, '` took ', round(end_time - start_time, 2), ' seconds.')
    
    return(fluo_calib)
    }


# function: baseline subtraction and Ct
baseline_ct <- function(fluo_calib, 
                        model, baselin, basecyc, # modlist parameters
                        type, cp, # getPar parameters
                        show_running_time=FALSE, # option to show time cost to run this function
                        
                        ...) {
    # start counting for running time
    func_name <- 'baseline_ct'
    start_time <- proc.time()[['elapsed']]
    
    # do the work
    fitted_curves <- modlist(fluo_calib, model=model, baseline=baselin, basecyc=basecyc)
    ct_eff <- getPar(fitted_curves, type=type, cp=cp)
    
    # report time cost for this function
    end_time <- proc.time()[['elapsed']]
    if (show_running_time) message('`', func_name, '` took ', round(end_time - start_time, 2), ' seconds.')
    
    return(list('fitted_curves'=fitted_curves, 'ct_eff'=ct_eff))
    }




