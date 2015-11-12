# amp


# function by Xia Hong
get_amplification_data <- function(db_usr, db_pwd, db_host, db_port, db_name, # for connecting to MySQL database
                                   exp_id, stage_id, calib_id, # for selecting data to analyze
                                   show_running_time=FALSE # option to show time cost to run this function
                                   ) {
    # baseline_ct
    model <- l4
    baselin <- 'parm'
    basecyc <- 1:5
    fallback <- 'lin'
    type <- 'curve'
    cp <- 'cpD2'
    
    # use functions
    amp_calib <- get_amp_calib(db_usr, db_pwd, db_host, db_port, db_name,
                               exp_id, stage_id, calib_id,
                               show_running_time) # 1.63-1.75 sec (1st time, 3 tests); 0.94-1.60 sec (2nd time and on, 5 tests)
    baseline_calib <- baseline_ct(amp_calib, model, baselin, basecyc, fallback, type, cp, show_running_time)
    return (list('background_subtracted'=amp_calib, 'baseline_subtracted'=baseline_calib['bl_corrected'], 'ct'=baseline_calib['ct_eff']))
    }


# function: get amplification data from MySQL database and perform water calibration 
get_amp_calib <- function(db_usr, db_pwd, db_host, db_port, db_name, # for connecting to MySQL database
                          exp_id, stage_id, calib_id, # for selecting data to analyze
                          show_running_time=FALSE # option to show time cost to run this function
                          ) {
    
    # start counting for running time
    func_name <- 'get_amp_calib'
    start_time <- proc.time()[['elapsed']]
    
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
    
    # get fluorescence data for amplification
    fluo_qry <- sprintf('SELECT step_id, fluorescence_value, well_num, cycle_num, ramp_id 
                            FROM fluorescence_data 
                            LEFT JOIN ramps ON fluorescence_data.ramp_id = ramps.id
                            INNER JOIN steps ON fluorescence_data.step_id = steps.id OR steps.id = ramps.next_step_id 
                            WHERE fluorescence_data.experiment_id=%d AND steps.stage_id=%d 
                            ORDER BY well_num, cycle_num',
                            exp_id, stage_id)
    fluo_sel <- dbGetQuery(db_conn, fluo_qry)
    
    # cast fluo_sel into a pivot table organized by cycle_num (row label) and well_num (column label), average the data from all the available steps/ramps for each well and cycle
    fluo_mlt <- melt(fluo_sel, id.vars=c('step_id', 'well_num', 'cycle_num', 'ramp_id'), 
                     measure.vars='fluorescence_value')
    fluo_cast <- dcast(fluo_mlt, cycle_num ~ well_num, mean)
    
    # get calibration data
    amp_calib <- cbind(fluo_cast[, 'cycle_num'], calib(fluo_cast[,2:(num_wells+1)], db_conn, calib_id))
    colnames(amp_calib)[1] <- 'cycle_num'
    
    # report time cost for this function
    end_time <- proc.time()[['elapsed']]
    if (show_running_time) message('`', func_name, '` took ', round(end_time - start_time, 2), ' seconds.')
    
    return(amp_calib)
    }


# function: baseline subtraction and Ct
baseline_ct <- function(amp_calib, 
                        model, baselin, basecyc, fallback, # modlist parameters. 
                        # baselin = c('none', 'mean', 'median', 'lin', 'quad', 'parm').
                        # fallback = c('none', 'mean', 'median', 'lin', 'quad'). only valid when baselin = 'parm'
                        type, cp, # getPar parameters
                        show_running_time=FALSE # option to show time cost to run this function
                        ) {
    # start counting for running time
    func_name <- 'baseline_ct'
    start_time <- proc.time()[['elapsed']]
    
    
    # using customized modlist and baseline functions
    mod_R1 <- modlist(amp_calib, model=model, baseline=baselin, basecyc=basecyc, fallback=fallback)
    mod_ori <- mod_R1[['ori']] # original output from qpcR function modlist
    coef_mtx <- do.call(cbind, lapply(mod_ori, 
        function(item) {
            coefs <- coef(item)
            if (is.null(coefs)) coefs <- NA
            return(coefs) })) # coefficients of sigmoid-fitted amplification curves
    colnames(coef_mtx) <- colnames(amp_calib)[2:ncol(amp_calib)]
    
    #bl_info <- mod_R1[['bl_info']] # baseline to subtract, which original modlist does not output
    bl_corrected <- mod_R1[['bl_corrected']] # fluorescence data corrected via baseline subtraction, which original modlist does not output
    rownames(bl_corrected) <- amp_calib[,'cycle_num']
    
    # using original modlist and baseline functions
    # mod_ori <- modlist(amp_calib, model=model, baseline=baselin, basecyc=basecyc)
    # coef_mtx <- NULL
    # bl_info <- NULL
    # bl_corrected <- NULL
    
    # threshold cycle and amplification efficiency
    ct_eff_raw <- getPar(mod_ori, type=type, cp=cp)
    ct_eff <- do.call(cbind, alply(ct_eff_raw, .margins=2, 
                                   .fun=function(col1) {
                                       ct <- col1['ct']
                                       ct_adj <- if (!is.na(ct) & ct == nrow(amp_calib)) NA else ct
                                       c(ct_adj, col1['eff']) }))
    rownames(ct_eff) <- rownames(ct_eff_raw)
    colnames(ct_eff) <- colnames(ct_eff_raw)
    
    # report time cost for this function
    end_time <- proc.time()[['elapsed']]
    if (show_running_time) message('`', func_name, '` took ', round(end_time - start_time, 2), ' seconds.')
    
    return(list('bl_corrected'=bl_corrected, 'coefficients'=coef_mtx, 'ct_eff'=ct_eff))
                # removed for performance: , 'mod_ori'=mod_ori, 'bl_info'=bl_info))
    }




