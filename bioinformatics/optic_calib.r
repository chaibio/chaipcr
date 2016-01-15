# calib

# function: check whether the data in optical calibration experiment is valid; if yes, prepare calibration data

prep_optic_calib <- function(db_conn, calib_id, verbose=FALSE) {
    
    calib_water_qry <-  sprintf('SELECT fluorescence_value, well_num 
                                    FROM fluorescence_data 
                                    WHERE experiment_id=%d AND step_id=2 
                                    ORDER BY well_num', 
                                    calib_id)
    calib_signal_qry <- sprintf('SELECT fluorescence_value, well_num 
                                    FROM fluorescence_data 
                                    WHERE experiment_id=%d AND step_id=4 
                                    ORDER BY well_num', 
                                    calib_id)
    
    calib_water  <- dbGetQuery(db_conn, calib_water_qry)
    calib_signal <- dbGetQuery(db_conn, calib_signal_qry)
    
    dw <- dim(calib_water)
    ds <- dim(calib_signal)
    
    if (!(all(dw == ds))) {
        stop(sprintf('dimensions of water and signal wells for calibration are not equal: calib_water(%i,%i) while calib_signal(%i,%i)', 
                     dw[1], dw[2], ds[1], ds[2])) }
    
    calib_water_fluo <- t(calib_water[,'fluorescence_value'])
    calib_signal_fluo <- t(calib_signal[,'fluorescence_value'])
    
    calib_invalid_vec <- (calib_signal_fluo - calib_water_fluo <= 0)
    if (any(calib_invalid_vec)) {
        if (verbose) message('Wells (1 = 1st well, etc.) with signal <= water fluorescence values: ', 
                             paste((1:dw[1])[calib_invalid_vec], collapse=', '))
        stop('Invalid calibration. Please perform a new optical calibration experiment.'
             ) }
             #, 
             #, paste((1:dw[1])[calib_invalid_vec], collapse=', ') }
    
    return(list('num_calib_wells'=dw[1], 
                'calib_water_fluo'=calib_water_fluo, 
                'calib_signal_fluo'=calib_signal_fluo))
}


# function: perform optical (water) calibration on fluo

optic_calib <- function(fluo, db_conn, calib_id, verbose=FALSE, show_running_time=FALSE) {
    
    # start counting for running time
    func_name <- 'calib'
    start_time <- proc.time()[['elapsed']]
    
    calib_data <- prep_optic_calib(db_conn, calib_id, verbose)
    
    if (!(calib_data$num_calib_wells == num_wells)) {
        stop('number of calibration wells is not equal to user-defined number of wells') }
    
    # perform calibration
    signal_water_diff <- calib_data$calib_signal_fluo - calib_data$calib_water_fluo
    fluo_calib <- adply(fluo, .margins=1, 
                        function(row1) scaling_factor * (row1 - calib_data$calib_water_fluo) / signal_water_diff)
    
    # report time cost for this function
    end_time <- proc.time()[['elapsed']]
    if (show_running_time) message('`', func_name, '` took ', round(end_time - start_time, 2), ' seconds.')
    
    return(list('fluo_calib'=fluo_calib, 
                'signal_water_diff' = scaling_factor * signal_water_diff))
}


