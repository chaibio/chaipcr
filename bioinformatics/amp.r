# amp


# function: get amplification data from MySQL database; perform water calibration.
get_amp_calib <- function(channel, # as 1st argument for iteration by channel
                          db_conn, 
                          exp_id, stage_id, calib_id, # for selecting data to analyze
                          show_running_time # option to show time cost to run this function
                          ) {
    
    # start counting for running time
    func_name <- 'get_amp_calib'
    start_time <- proc.time()[['elapsed']]
    
    message('get_amp_calib') # Xia Hong
    
    # get fluorescence data for amplification
    fluo_qry <- sprintf('SELECT step_id, fluorescence_value, well_num, cycle_num, ramp_id, channel 
                            FROM fluorescence_data 
                            LEFT JOIN ramps ON fluorescence_data.ramp_id = ramps.id
                            INNER JOIN steps ON fluorescence_data.step_id = steps.id OR steps.id = ramps.next_step_id 
                            WHERE fluorescence_data.experiment_id=%d AND steps.stage_id=%d AND fluorescence_data.channel=%d 
                            ORDER BY well_num, cycle_num',
                            exp_id, stage_id, as.numeric(channel))
    fluo_sel <- dbGetQuery(db_conn, fluo_qry)
    
    # cast fluo_sel into a pivot table organized by cycle_num (row label) and well_num (column label), average the data from all the available steps/ramps for each well and cycle
    fluo_mlt <- melt(fluo_sel, id.vars=c('step_id', 'well_num', 'cycle_num', 'ramp_id'), 
                     measure.vars='fluorescence_value')
    fluo_cast <- dcast(fluo_mlt, cycle_num ~ well_num, mean)
    
    # get optical-calibrated data.
    calibd <- optic_calib(fluo_cast[,2:(num_wells+1)], db_conn, calib_id, channel, show_running_time)$fluo_calib # column cycle_num is included, because adply automatically create a column at index 1 of output from rownames of input array (1st argument)
    ac_mtx <- cbind(fluo_cast[, 'cycle_num'], calibd)
    colnames(ac_mtx)[1] <- 'cycle_num'
    amp_calib <- list('ac_mtx'=as.matrix(ac_mtx), # change data frame to matrix for ease of constructing array
                      'signal_water_diff'=calibd$signal_water_diff)
    
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
get_ct_eff <- function(
                       bl_corrected, # used to calculate rsem and rser, not as input for Ct determination
                       # ac_mtx, 
                       # signal_water_diff, 
                       mod_ori, 
                       # min_ac_max, # the threshold which maximum (fluo value / scaling factor) of the well needs to exceed, for Ct to be reported as actual value instead of NA
                       max_rsem, max_rser, # maximum residual standard error divided by absolute value of mean or range, for Ct to be reported as actual value instead of NA
                       type, cp, 
                       num_cycles) {
    
    # ac_maxs <- unlist(alply(ac_mtx, .margins=2, max))[2:ncol(ac_mtx)] / scaling_factor
    # ac_calib_ratios <- unlist(alply(ac_mtx, .margins=2, max))[2:ncol(ac_mtx)] / signal_water_diff
    # well_names <- colnames(ac_mtx)[2:ncol(ac_mtx)]
    
    well_names <- colnames(bl_corrected)
    
    ct_eff_raw <- getPar(mod_ori, type=type, cp=cp)
    tagged_colnames <- colnames(ct_eff_raw)
    colnames(ct_eff_raw) <- well_names
    
    rsems <- c()
    rsers <- c()
    finIters <- c()
    adj_reasons <- list() # c() isn't pretty for view
    ct_eff_adj <- ct_eff_raw
    
    for (i in 1:num_wells) {
        
        # ac_max <- ac_maxs[i]
        # ac_calib_ratio <- ac_calib_ratios[i]
        
        mod <- mod_ori[[i]]
        stopCode <- mod$convInfo$stopCode
        b <- coef(mod)[['b']]
        
        rse <- tryCatch(sigma(mod), error=function(e) NA) # residual standard error of fitted amplification curve
        rsem <- rse / abs(mean(bl_corrected[,i])) # divided by absolute value of mean fluo over all cycles for each well
        rsems[i] <- rsem
        rser <- rse / diff(range(bl_corrected[,i])) # divided by fluo range over all cycles for each well
        rsers[i] <- rser
        
        # `finIters[[i]]` <- NULL will not create element i for `finIters`
        finIter <- mod$convInfo$finIter
        if (is.null(finIter)) finIters[i] <- NA else finIters[i] <- finIter
        
        ct <- ct_eff_adj['ct', i]
        
        # if        (ac_max < min_ac_max) {
            # adj_reasons[[i]] <- paste('ac_max < min_ac_max. ac_max == ', ac_max, '. min_ac_max ==', min_ac_max, 
                                      # sep='')
        if        (is.na(rse)) {
            adj_reasons[[i]] <- 'error on sigma'
        } else if (rsem > max_rsem & rser > max_rser) {
            adj_reasons[[i]] <- paste('rsem > max_rsem & rser > max_rser. rsem == ', rsem, '. max_rsem == ', max_rsem, '. rser == ', rser, '. max_rser == ', max_rser, 
                                      sep='')
        } else if (is.null(b)) {
            adj_reasons[[i]] <- 'is.null(b)'
        } else if (b > 0) {
            adj_reasons[[i]] <- 'b > 0'
        } else if (is.null(stopCode)) {
            adj_reasons[[i]] <- 'is.null(stopCode)'
        # } else if (stopCode == -1) { # may not be accurate enough
            # adj_reasons[[i]] <- 'Number of iterations has reached `maxiter`'
        } else if (!is.na(ct) && ct == num_cycles) {
            adj_reasons[[i]] <- 'ct == num_cycles'
        } else {
            adj_reasons[[i]] <- 'none' }
        
        if (adj_reasons[[i]] != 'none') ct_eff_adj['ct', i] <- NA 
        
        }
    
    # names(ac_maxs) <- well_names
    
    names(rsems) <- well_names
    names(rsers) <- well_names
    names(finIters) <- well_names
    names(adj_reasons) <- well_names
    
    rownames(ct_eff_adj) <- rownames(ct_eff_raw)
    colnames(ct_eff_adj) <- well_names
    
    return(list('adj'=ct_eff_adj, 
                # 'ac_maxs'=ac_maxs, 
                'raw'=ct_eff_raw, 'rsems'=rsems, 'rsers'=rsers, 'finIters'=finIters, 'reasons'=adj_reasons, # for debugging
                'tagged_colnames'=tagged_colnames
                ))
    }


# function: baseline subtraction and Ct
baseline_ct <- function(amp_calib, 
                        model, baselin, basecyc, fallback, # modlist parameters. 
                        # baselin = c('none', 'mean', 'median', 'lin', 'quad', 'parm').
                        # fallback = c('none', 'mean', 'median', 'lin', 'quad'). only valid when baselin = 'parm'
                        maxiter, maxfev, # control parameters for `nlsLM` in `pcrfit`. !!!! Note: `maxiter` sometimes affect finIter in a weird way: e.g. for the same well, finIter == 17 when maxiter == 200, finIter == 30 when maxiter == 30, finIter == 100 when maxiter == 100; maxiter affect fitting strategy?
                        # min_ac_max, # get_ct_eff parameter to control Ct reporting
                        max_rsem, max_rser, # get_ct_eff parameter to control Ct reporting
                        type, cp, # getPar parameters
                        show_running_time # option to show time cost to run this function
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
    
    # # normalize bl_corrected so the median fluorescence values in basecyc (basecyc_medians) for all the wells in each channel are adjusted to the median of original basecyc_medians
    # basecyc_medians <- unlist(alply(bl_corrected, .margins=2, 
                                    # .fun=function(col1) median(col1[basecyc])))
    # bm_adjm <- basecyc_medians - median(basecyc_medians)
    # bl_normd <- do.call(rbind, alply(bl_corrected, .margins=1,
                                     # .fun=function(row1) row1 - bm_adjm))
    
    # threshold cycle and amplification efficiency
    ct_eff <- get_ct_eff(bl_corrected, # has to be consistent with mod_ori, therefore can't be bl_normd
                         # signal_water_diff, 
                         mod_ori, 
                         # min_ac_max=min_ac_max, 
                         max_rsem=max_rsem, max_rser=max_rser, 
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
                # 'bl_normd'=bl_normd, 
                # 'ac_maxs'=ct_eff[['ac_maxs']], 
                'rsems'=ct_eff[['rsems']], 'rsers'=ct_eff[['rsers']], 'finIters'=ct_eff[['finIters']], 'adj_reasons'=ct_eff[['reasons']], 'ct_eff_raw'=ct_eff[['raw']], 'ct_eff_tagged_colnames'=ct_eff[['tagged_colnames']], # outputs from `get_ct_eff` for debugging
                'ct_eff'=ct_eff[['adj']] ))
    }


# top level function called by external codes
get_amplification_data <- function(db_usr, db_pwd, db_host, db_port, db_name, # for connecting to MySQL database
                                   exp_id, stage_id, calib_id, # for selecting data to analyze
                                   dcv=TRUE, # logical, whether to perform multi-channel deconvolution
                                   # basecyc, cp, # extra parameters that are currently hard-coded but may become user-defined later
                                   extra_output=FALSE, 
                                   show_running_time=FALSE # option to show time cost to run this function
                                   ) {
    
    # baseline_ct
    model <- l4
    baselin <- 'auto_lin' # used: 'auto_lin', 'lin', 'parm'
    basecyc <- 3:6 # will be overwritten if (grepl('^auto_', baseline)). used: 15:20, 10:15, 3:6, 1:5 (gave poor baseline subtraction results for non-sigmoid shaped data when using 'lin')
    fallback <- 'median' # used: 'auto_lin', 'lin', 'median'
    maxiter <- 500
    maxfev <- 10000
    # min_ac_max <- 0
    max_rsem <- 1.2 # used: 0.1
    max_rser <- 0.3 # used: 0.025
    type <- 'curve'
    cp <- 'cpD2'
    
    db_conn <- db_etc(db_usr, db_pwd, db_host, db_port, db_name, 
                      exp_id, stage_id, calib_id)
    
    fd_qry <- sprintf('SELECT * FROM fluorescence_data 
                           LEFT JOIN ramps ON fluorescence_data.ramp_id = ramps.id
                           INNER JOIN steps ON fluorescence_data.step_id = steps.id OR steps.id = ramps.next_step_id 
                           WHERE fluorescence_data.experiment_id=%d AND steps.stage_id=%d
                           ORDER BY well_num, cycle_num, channel',
                           exp_id, stage_id)
    fluorescence_data <- dbGetQuery(db_conn, fd_qry)
    
    channels <- unique(fluorescence_data[,'channel'])
    names(channels) <- channels
    
    if (length(channels) == 1) dcv <- FALSE
    
    amp_calib_mtch <- process_mtch(channels, 
                                   matrix2array=TRUE, 
                                   func=get_amp_calib, 
                                   db_conn, 
                                   exp_id, stage_id, calib_id, 
                                   show_running_time)
    
    amp_calib_mtch_bych <- amp_calib_mtch[['pre_consoli']]
    
    amp_calib_array <- amp_calib_mtch[['post_consoli']][['ac_mtx']]
    
    bg_sub <- amp_calib_array
    
    if (dcv) {
        aca_dim3 <- dim(amp_calib_array)[3]
        ac2dcv <- amp_calib_array[,,2:aca_dim3]
        dcvd_array <- deconv(ac2dcv, k_list[['k_inv_array']])
        for (channel in channels) {
            dcvd_mtx_per_channel <- dcvd_array[as.character(channel),,]
            amp_calib_mtch_bych[[as.character(channel)]][['ac_mtx']][,2:aca_dim3] <- dcvd_mtx_per_channel
            bg_sub[as.character(channel),,2:aca_dim3] <- dcvd_mtx_per_channel }}
    
    baseline_ct_mtch <- process_mtch(amp_calib_mtch_bych, 
                                     matrix2array=FALSE, 
                                     func=baseline_ct, 
                                     model, baselin, basecyc, fallback, 
                                     maxiter, maxfev, 
                                     # min_ac_max, 
                                     max_rsem, max_rser, 
                                     type, cp, 
                                     show_running_time)[['post_consoli']]
    baseline_ct_mtch[['pre_dcv_bg_sub']] <- amp_calib_array
    
    bg_sub <- lapply(channels, function(channel) bg_sub[channel,,]) # for list instead of array output
    
    downstream <- list('background_subtracted'=bg_sub, 
                       'baseline_subtracted'=baseline_ct_mtch[['bl_corrected']], 
                       'ct'=baseline_ct_mtch[['ct_eff']], 
                       'coefficients'=baseline_ct_mtch[['coefficients']]
                       )
    
    if (extra_output) {
        result_mtch <- c(downstream, baseline_ct_mtch)
        result_mtch[['fluorescence_data']] <- fluorescence_data
    } else result_mtch <- downstream
    
    return(result_mtch)
    }




