# meltcrv


# function: get melting curve data and output it for plotting as well as Tm
process_mc <- function(db_usr, db_pwd, db_host, db_port, db_name, # for connecting to MySQL database
                       exp_id, stage_id, calib_id, # for selecting data to analyze
                       show_running_time=FALSE, # option to show time cost to run this function
                       ... # options to pass onto `meltcurve`
                       ) {
    
    # start counting for running time
    func_name <- 'process_mc'
    start_time <- proc.time()[['elapsed']]

    mc_calib <- get_mc_calib(db_usr, db_pwd, db_host, db_port, db_name,
                             exp_id, stage_id, calib_id,
                             show_running_time)
    mc_out <- mc_tm_all(mc_calib, show_running_time, ...)
    
    # report time cost for this function
    end_time <- proc.time()[['elapsed']]
    if (show_running_time) message('`', func_name, '` took ', round(end_time - start_time, 2), ' seconds.')
    
    return(mc_out)
    }


# function: get melting curve data from MySQL database and perform water calibration
get_mc_calib <- function(db_usr, db_pwd, db_host, db_port, db_name, # for connecting to MySQL database
                         exp_id, stage_id, calib_id, # for selecting data to analyze
                         show_running_time=FALSE # option to show time cost to run this function
                         ) {
    
    # start counting for running time
    func_name <- 'get_mc_calib'
    start_time <- proc.time()[['elapsed']]
    message('get_mc_calib')
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
    
    # get fluorescence data for melting curve
    fluo_qry <- sprintf('SELECT id, stage_id, well_num, temperature, fluorescence_value, experiment_id 
                            FROM melt_curve_data 
                            WHERE experiment_id=%d AND stage_id=%d 
                            ORDER BY well_num, temperature',
                            exp_id, stage_id)
    fluo_sel <- dbGetQuery(db_conn, fluo_qry)
    
    # split temperature and fluo data by well_num
    tf_list <- split(fluo_sel[, c('temperature', 'fluorescence_value')], fluo_sel$well_num)
    # add NA to the end if not enough data
    max_len <- max(sapply(tf_list, function(tf) dim(tf)[1]))
    tf_ladj <- lapply(tf_list, function(tf) rbind(as.matrix(tf), matrix(NA, nrow=(max_len-dim(tf)[1]), ncol=2)))
    # water calibration
    fluo_mtx <- do.call(cbind, lapply(tf_ladj, function(tf) tf[, 'fluorescence_value']))
    fluo_calib <- calib(fluo_mtx, db_conn, calib_id, show_running_time)[,2:(num_wells+1)]
    # combine temperature and fluo data
    fluo_calib_list <- alply(fluo_calib, .margins=2, .fun=function(col1) col1)
    mc_calib <- do.call(cbind, lapply(1:num_wells, function(well_num) cbind(tf_ladj[[well_num]][, 'temperature'], 
                                                                            fluo_calib_list[[well_num]])))
    colnames(mc_calib) <- paste(rep(c('temp', 'fluo'), times=num_wells), rep(unique(fluo_sel$well_num), each=2), sep='_')
    
    # report time cost for this function
    end_time <- proc.time()[['elapsed']]
    if (show_running_time) message('`', func_name, '` took ', round(end_time - start_time, 2), ' seconds.')
    
    return(mc_calib)
    }


# function: extract melting curve data and Tm for each well
mc_tm_pw <- function(mt_pw) { # per well
    mc <- mt_pw[, c('Temp', 'Fluo', 'df.dT')]
    tm <- na.omit(mt_pw[, c('Tm', 'Area')])
    return(list('mc'=mc, 'tm'=tm))
    }


# function: output melting curve data and Tm for all the wells
mc_tm_all <- function(mc_calib, show_running_time=FALSE, 
                      ...) { # options to pass onto `meltcurve`
    
    # start counting for running time
    func_name <- 'mc_tm_all'
    start_time <- proc.time()[['elapsed']]
    
    mt_ori <- meltcurve(mc_calib, ...)
    mt_out <- lapply(mt_ori, mc_tm_pw)
    names(mt_out) <- colnames(mc_calib)[seq(2, dim(mc_calib)[2], by=2)]
    
    # report time cost for this function
    end_time <- proc.time()[['elapsed']]
    if (show_running_time) message('`', func_name, '` took ', round(end_time - start_time, 2), ' seconds.')
    
    # Return a named list whose length is number of wells. 
    # The name of each element is in the format of `paste('fluo', well_name, sep='_')`
    return(mt_out)
    }








