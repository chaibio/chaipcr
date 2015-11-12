# calib

# function: water calibration

calib <- function(fluo, db_conn, calib_id) {
    
    # start counting for running time
    func_name <- 'calib'
    start_time <- proc.time()[['elapsed']]
    
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
    fluo_calib <- adply(fluo, .margins=1, 
                        function(row1) scaling_factor
                                           * (row1 - calib_water_fluo) 
                                           / (calib_signal_fluo - calib_water_fluo))
    
    # report time cost for this function
    end_time <- proc.time()[['elapsed']]
    if (show_running_time) message('`', func_name, '` took ', round(end_time - start_time, 2), ' seconds.')
    
    return(fluo_calib)
    }
