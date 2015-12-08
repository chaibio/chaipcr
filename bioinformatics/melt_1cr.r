# melt curve data and fluorescence within 1C range

melt_1cr <- function(floor_temp, 
                     db_usr, db_pwd, db_host, db_port, db_name, 
                     exp_id, 
                     stage_id, 
                     calib_id, 
                     verbose=FALSE, 
                     show_running_time=FALSE) {
    
    # start counting for running time
    func_name <- 'melt_1cr'
    start_time <- proc.time()[['elapsed']]
    
    # get calibrated melting curve data
    mc_calib <- get_mc_calib(db_usr, db_pwd, db_host, db_port, db_name, 
                             exp_id, stage_id, calib_id, 
                             verbose, 
                             show_running_time)
    
    # get melting curve data for all the temperatures as well as Tm
    mc_out <- mc_tm_all(mc_calib, show_running_time)
    
    # For each well, average the calibrated fluorescence values for the temperatures 72-73C
    mc_cols <- colnames(mc_calib)
    temp_cols <- mc_cols[grepl('temp', mc_cols)]
    fluo_cols <- mc_cols[grepl('fluo', mc_cols)]
    if (length(temp_cols) != length(fluo_cols)) {
        stop('Number of temperature columns is not equal to number of fluorescence columns.') }
    tempsl_1cr <- alply(mc_calib[,temp_cols], .margins=2, 
                        .fun=function(temps_pw) {
                            tempsl <- temps_pw >= floor_temp & temps_pw < floor_temp + 1
                            tempsl[is.na(tempsl)] <- FALSE
                            return(tempsl)
                            })
    fluo_1cr <- sapply(1:length(fluo_cols), 
                       function(i) mean(mc_calib[tempsl_1cr[[i]], fluo_cols[i]]))
    names(fluo_1cr) <- fluo_cols
    
    mc_w1cr <- list('mc_out'=mc_out, '1cr_fluorescence'=fluo_1cr)
    
    # report time cost for this function
    end_time <- proc.time()[['elapsed']]
    if (show_running_time) message('`', func_name, '` took ', round(end_time - start_time, 2), ' seconds.')
    
    return(mc_w1cr)
}
