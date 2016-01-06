# amp

# function by Xia Hong
get_amplification_data <- function(db_usr, db_pwd, db_host, db_port, db_name, # for connecting to MySQL database
                                   exp_id, stage_id, calib_id, # for selecting data to analyze
                                   verbose=FALSE, 
                                   show_running_time=FALSE # option to show time cost to run this function
                                   ) {
    # baseline_ct
    model <- l4
    baselin <- 'parm'
    basecyc <- 3:6 # 1:5 gave poor baseline subtraction results for non-sigmoid shaped data when using 'lin'
    fallback <- 'lin'
    maxiter <- 20
    maxfev <- 10000
    type <- 'curve'
    cp <- 'cpD2'
    
    # use functions
    amp_calib <- get_amp_calib(db_usr, db_pwd, db_host, db_port, db_name, 
                               exp_id, stage_id, calib_id, 
                               verbose, 
                               show_running_time)
    baseline_calib <- baseline_ct(amp_calib, model, baselin, basecyc, fallback, 
                                  maxiter, maxfev, 
                                  type, cp, 
                                  show_running_time)
    return (list('background_subtracted'=amp_calib, 'baseline_subtracted'=baseline_calib['bl_corrected'], 'ct'=baseline_calib['ct_eff']))
    }


# function: get amplification data from MySQL database and perform water calibration 
get_amp_calib <- function(db_usr, db_pwd, db_host, db_port, db_name, # for connecting to MySQL database
                          exp_id, stage_id, calib_id, # for selecting data to analyze
                          verbose=FALSE, 
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
    amp_calib <- cbind(fluo_cast[, 'cycle_num'], 
                       optic_calib(fluo_cast[,2:(num_wells+1)], db_conn, calib_id, verbose, show_running_time))
    colnames(amp_calib)[1] <- 'cycle_num'
    
    # report time cost for this function
    end_time <- proc.time()[['elapsed']]
    if (show_running_time) message('`', func_name, '` took ', round(end_time - start_time, 2), ' seconds.')
    
    return(amp_calib)
    }


# function: extract coefficients as a matrix from a modlist object
modlist_coef <- function(modLIST, coef_cols) {
    coef_list <- lapply(modLIST, 
        function(item) {
            if (is.na(item)) coefs <- NA else coefs <- coef(item)
            if (is.null(coefs)) coefs <- NA
            return(coefs) }) # coefficients of sigmoid-fitted models
    coef_mtx <- do.call(cbind, coef_list) # coefficients of sigmoid-fitted models
    colnames(coef_mtx) <- coef_cols
    return(coef_mtx)
    }


# function: baseline subtraction and Ct
baseline_ct <- function(amp_calib, 
                        model, baselin, basecyc, fallback, # modlist parameters. 
                        # baselin = c('none', 'mean', 'median', 'lin', 'quad', 'parm').
                        # fallback = c('none', 'mean', 'median', 'lin', 'quad'). only valid when baselin = 'parm'
                        maxiter, maxfev, # control parameters for `nlsLM` in `pcrfit`
                        type, cp, # getPar parameters
                        show_running_time=FALSE # option to show time cost to run this function
                        ) {
    
    if (dim(amp_calib)[1] <= 2) {
        message('Two or fewer cycles of fluorescence data are available. Baseline subtraction and calculation of Ct and amplification efficiency cannot be performed.')
        ct_eff <- matrix(NA, nrow=2, ncol=num_wells, 
                         dimnames=list(c('ct', 'eff'), colnames(amp_calib)[2:(num_wells+1)]))
        
        return(list('bl_corrected'=amp_calib[,2:(num_wells+1)], 'ct_eff'=ct_eff))
        }
    
    # start counting for running time
    func_name <- 'baseline_ct'
    start_time <- proc.time()[['elapsed']]
    
    control <<- nls.lm.control(maxiter=maxiter, maxfev=maxfev) # define as a global variable to be used in `nlsLM` in `pcrfit`. If not set, (maxiter = 1000, maxfev = 10000) will be used.
    
    # using customized modlist and baseline functions
    
    mod_R1 <- modlist(amp_calib, model=model, baseline=baselin, basecyc=basecyc, fallback=fallback)
    mod_ori <- mod_R1[['ori']] # original output from qpcR function modlist
    well_names <- colnames(amp_calib)[2:ncol(amp_calib)]
    mod_ori_cm <- modlist_coef(mod_ori, well_names) # coefficients of sigmoid-fitted amplification curves
    
    if (baselin == 'parm') { # prepare output for baseline subtraction sigmoid fitting
      fluoa <- mod_R1[['fluoa']] # fluorecence with addition to ensure not all negative
      num_cycles <- dim(fluoa)[1]
      blmods <- mod_R1[['blmods']] # sigmoid models fitted during baseline subtraction thru 'parm'
      blmods_cm <- modlist_coef(blmods, well_names) # coefficients for sigmoid-fitted models fitted during baseline subtraction thru 'parm'
      fluo_blmods <- do.call(cbind, 
                             lapply(well_names, 
                                    function(well_name) 
                                      sapply(1:num_cycles, model$fct, blmods_cm[,well_name])))
      colnames(fluo_blmods) <- well_names
    } else {
      fluoa <- NULL
      blmods <- NULL
      blmods_cm <- NULL
      fluo_blmods <- NULL
      }
    
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
    
    return(list(
                'mod_ori'=mod_ori, 
                # 'bl_info'=bl_info, # removed for performance
                'fluoa'=fluoa, 'bl_coefs'=blmods_cm, 'fluo_blmods'=fluo_blmods, 
                'bl_corrected'=bl_corrected, 'coefficients'=mod_ori_cm, 'ct_eff'=ct_eff))
    }




