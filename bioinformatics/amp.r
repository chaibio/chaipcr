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
    maxiter <- 200
    maxfev <- 10000
    min_ac_max <- 10
    type <- 'curve'
    cp <- 'cpD2'
    
    # use functions
    amp_calib <- get_amp_calib(db_usr, db_pwd, db_host, db_port, db_name, 
                               exp_id, stage_id, calib_id, 
                               verbose, 
                               show_running_time)
    baseline_calib <- baseline_ct(amp_calib, model, baselin, basecyc, fallback, 
                                  maxiter, maxfev, 
                                  min_ac_max, 
                                  type, cp, 
                                  show_running_time)
    return (list('background_subtracted'=amp_calib[['ac_mtx']], # Xiaoqing Rong-Mullins: retrieve unnamed element
                 'baseline_subtracted'=baseline_calib['bl_corrected'], 'ct'=baseline_calib['ct_eff'] # Xia Hong: retrieve named elements
                 ))
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
    
    message('get_amp_calib') # Xia Hong
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
    calib_out <- optic_calib(fluo_cast[,2:(num_wells+1)], db_conn, calib_id, verbose, show_running_time)
    ac_mtx <- cbind(fluo_cast[, 'cycle_num'], calib_out$fluo_calib)
    colnames(ac_mtx)[1] <- 'cycle_num'
    amp_calib <- list('ac_mtx'=ac_mtx, 'signal_water_diff'=calib_out$signal_water_diff)
    
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


# function: get Ct and amplification efficiency values
get_ct_eff <- function(ac_mtx, 
                       # signal_water_diff, 
                       mod_ori, 
                       min_ac_max, 
                       type, cp, 
                       num_cycles) {
    
    ac_maxs <- unlist(alply(ac_mtx, .margins=2, max))[2:ncol(ac_mtx)] / scaling_factor
    # ac_calib_ratios <- unlist(alply(ac_mtx, .margins=2, max))[2:ncol(ac_mtx)] / signal_water_diff
    
    ct_eff_raw <- getPar(mod_ori, type=type, cp=cp)
    
    finIters <- list()
    adj_reasons <- list()
    ct_eff_adj <- ct_eff_raw
    
    for (i in 1:num_wells) {
        
        ac_max <- ac_maxs[i]
        # ac_calib_ratio <- ac_calib_ratios[i]
        
        mod <- mod_ori[[i]]
        finIters[[i]] <- mod$convInfo$finIter
        stopCode <- mod$convInfo$stopCode
        b <- coef(mod)[['b']]
        
        ct <- ct_eff_adj['ct', i]
        
        if        (ac_max < min_ac_max) {
            adj_reasons[[i]] <- paste('ac_max < min_ac_max. ac_max == ', ac_max, '. min_ac_max ==', min_ac_max, 
                                      sep='')
        } else if (is.null(b)) {
            adj_reasons[[i]] <- 'is.null(b)'
        } else if (b > 0) {
            adj_reasons[[i]] <- 'b > 0'
        } else if (is.null(stopCode)) {
            adj_reasons[[i]] <- 'is.null(stopCode)'
        } else if (stopCode != 1) {
            adj_reasons[[i]] <- paste('stopCode ==', stopCode)
        } else if (!is.na(ct) && ct == num_cycles) {
            adj_reasons[[i]] <- 'ct == num_cycles'
        } else {
            adj_reasons[[i]] <- 'none' }
        
        if (adj_reasons[[i]] != 'none') ct_eff_adj['ct', i] <- NA 
        
        }
    
    names(ac_maxs) <- colnames(ct_eff_raw)
    
    finIters <- unlist(finIters)
    names(finIters) <- colnames(ct_eff_raw)
    
    names(adj_reasons) <- colnames(ct_eff_raw)
    
    rownames(ct_eff_adj) <- rownames(ct_eff_raw)
    colnames(ct_eff_adj) <- colnames(ct_eff_raw)
    
    return(list(
                'ac_maxs'=ac_maxs, 'raw'=ct_eff_raw, 'finIters'=finIters, 'reasons'=adj_reasons, # for debugging
                'adj'=ct_eff_adj))
    }


# function: baseline subtraction and Ct
baseline_ct <- function(amp_calib, 
                        model, baselin, basecyc, fallback, # modlist parameters. 
                        # baselin = c('none', 'mean', 'median', 'lin', 'quad', 'parm').
                        # fallback = c('none', 'mean', 'median', 'lin', 'quad'). only valid when baselin = 'parm'
                        maxiter, maxfev, # control parameters for `nlsLM` in `pcrfit`. !!!! Note: `maxiter` sometimes affect finIter in a weird way: e.g. for the same well, finIter == 17 when maxiter == 200, finIter == 30 when maxiter == 30, finIter == 100 when maxiter == 100
                        min_ac_max, # get_ct_eff parameter to control Ct reporting
                        type, cp, # getPar parameters
                        show_running_time=FALSE # option to show time cost to run this function
                        ) {
    
    ac_mtx <- amp_calib$ac_mtx
    signal_water_diff <- amp_calib$signal_water_diff
    
    if (dim(ac_mtx)[1] <= 2) {
        message('Two or fewer cycles of fluorescence data are available. Baseline subtraction and calculation of Ct and amplification efficiency cannot be performed.')
        ct_eff <- matrix(NA, nrow=2, ncol=num_wells, 
                         dimnames=list(c('ct', 'eff'), colnames(ac_mtx)[2:(num_wells+1)]))
        return(list('bl_corrected'=ac_mtx[,2:(num_wells+1)], 'ct_eff'=ct_eff))
        }
    
    # start counting for running time
    func_name <- 'baseline_ct'
    start_time <- proc.time()[['elapsed']]
    
    control <<- nls.lm.control(maxiter=maxiter, maxfev=maxfev) # define as a global variable to be used in `nlsLM` in `pcrfit`. If not set, (maxiter = 1000, maxfev = 10000) will be used.
    
    # using customized modlist and baseline functions
    
    mod_R1 <- modlist(ac_mtx, model=model, baseline=baselin, basecyc=basecyc, fallback=fallback)
    mod_ori <- mod_R1[['ori']] # original output from qpcR function modlist
    well_names <- colnames(ac_mtx)[2:ncol(ac_mtx)]
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
    rownames(bl_corrected) <- ac_mtx[,'cycle_num']
    
    # using original modlist and baseline functions
    # mod_ori <- modlist(ac_mtx, model=model, baseline=baselin, basecyc=basecyc)
    # coef_mtx <- NULL
    # bl_info <- NULL
    # bl_corrected <- NULL
    
    # threshold cycle and amplification efficiency
    ct_eff <- get_ct_eff(ac_mtx, 
                         # signal_water_diff, 
                         mod_ori, 
                         min_ac_max=min_ac_max, 
                         type=type, cp=cp, 
                         num_cycles=nrow(ac_mtx))
    
    # report time cost for this function
    end_time <- proc.time()[['elapsed']]
    if (show_running_time) message('`', func_name, '` took ', round(end_time - start_time, 2), ' seconds.')
    
    return(list(
                'mod_ori'=mod_ori, 
                # 'bl_info'=bl_info, # removed for performance
                'fluoa'=fluoa, 'bl_coefs'=blmods_cm, 'fluo_blmods'=fluo_blmods, 
                'bl_corrected'=bl_corrected, 'coefficients'=mod_ori_cm, 
                'ac_maxs'=ct_eff[['ac_maxs']], 'finIters'=ct_eff[['finIters']], 'adj_reasons'=ct_eff[['reasons']], 'ct_eff_raw'=ct_eff[['raw']], # outputs from `get_ct_eff` for debugging
                'ct_eff'=ct_eff[['adj']] ))
    }




