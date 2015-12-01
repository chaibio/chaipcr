#load RMySQL library for reading from the database
library(jsonlite)

analyze <- function(db_usr, db_pwd, db_host, db_port, db_name, 
                    exp_id, 
                    #stage_id, # may be hard-coded inside of the function
                    calib_id, 
                    show_running_time=FALSE) {
    
    # start counting for running time
    func_name <- 'analyze'
    start_time <- proc.time()[['elapsed']]
    
    # hard-coded arguments
    stage_id <- 4
    
    # get calibrated melting curve data
    mc_calib <- get_mc_calib(db_usr, db_pwd, db_host, db_port, db_name, 
                             exp_id, stage_id, calib_id, 
                             show_running_time)
    
    # get melting curve data for all the temperatures as well as Tm
    mc_out <- mc_tm_all(mc_calib, show_running_time)
    
    # For each well, average the calibrated fluorescence values for the temperatures 72-73C
    mc_cols <- colnames(mc_calib)
    temp_cols <- mc_cols[grepl('temp', mc_cols)]
    fluo_cols <- mc_cols[grepl('fluo', mc_cols)]
    if (length(temp_cols) != length(fluo_cols)) {
        stop('Number of temperature columns is not equal to number of fluorescence columns.') }
    tempsl_72c <- alply(mc_calib[,temp_cols], .margins=2, 
                        .fun=function(temps_pw) {
                            tempsl <- temps_pw >= 72 & temps_pw < 73
                            tempsl[is.na(tempsl)] <- FALSE
                            return(tempsl)
                            })
    fluo_72c <- sapply(1:length(fluo_cols), 
                       function(i) mean(mc_calib[tempsl_72c[[i]], fluo_cols[i]]))
    names(fluo_72c) <- fluo_cols
    
    results <- list('mc_out'=mc_out, '72c_fluorescence'=fluo_72c)
    
    # report time cost for this function
    end_time <- proc.time()[['elapsed']]
    if (show_running_time) message('`', func_name, '` took ', round(end_time - start_time, 2), ' seconds.')
    
    #return(results) # for testing
    return(toJSON(results))
}
