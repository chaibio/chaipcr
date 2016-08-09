# amp


# top level function called by external codes
get_amplification_data <- function(
    db_usr, db_pwd, db_host, db_port, db_name, # for connecting to MySQL database
    exp_id, stage_id, calib_info, # for selecting data to analyze
    min_reliable_cyc=5, # needs to be an integer >= 1
    dye_in='FAM', dyes_2bfild=NULL, # fill missing channels in calibration experiment(s) using preset calibration experiments
    dcv=TRUE, # logical, whether to perform multi-channel deconvolution
    # basecyc, cp, # extra parameters that are currently hard-coded but may become user-defined later
    cp='Cy0', # used: 'cpD2', 'Cy0'
    max_cycle=1000, # maximum cycles to analyze
    
    min_fluomax=4356, # 34.03 before 128x. to increase, make sure pass up min 4356.921178 (ip 223, exp 38, channel 1, well A2); to decrease, make sure suppress no up max
    min_D1max=472, # 3.016 before 128x. to increase, make sure pass up min , consider 386.688335 (ip 201, exp 148, channel 1, well B3, nD1max 0.006732); to decrease, make sure supress no up max 
    min_D2max=41, # 0.32 before 128x. to increase, make sure pass up min2 41.381305 (ip 223, exp 220, channel 1, well A4), min1 45.521545 (ip 223, exp 46, channel 2, well B4), consider 28.020826 (ip 223, exp 220, channel 1, well B6); to decrease, make sure supress no up max 
    
    qt_prob=0.9,
    min_fluo_ratio=0.086, # to increase, make sure pass up min2 0.080584 (ip 223, exp 216, channel 1, well A6, can't pass `min_nD1max`), min1 0.086440 (ip 223, exp 37, channel 2, well B6), consider 0.073638 (ip 223, exp 222, channel 2, well B7, `cq > cpD1 && cp == Cy0`, `nD1max == 0.003909759`); to decrease, make sure suppress no up max 0.02113712 (ip 201, exp 4, well B5, suppressed by min_nD1max=0.013 > 0.0015856031, min_nD2max=0.0013 > 0.0002110152)
    min_nD1max=0.0095, # to increase, make sure pass up min3 0.009514 (ip 201, exp 35, channel 1, well A5), min2 0.009858 (ip 223, exp 220, channel 2, well B4), min1 0.009898 (ip 201, exp 148, channel 1, well B8), consider 0.006732 (ip 201, exp 148, channel 1, well B3); to decrease, make sure suppress no up max 0.009544 (ip 223, exp 175, channel 1, well A1)
    min_nD2max=0.000689, # to increase, make sure pass up min5 0.000690 (ip 201, exp 35, channel 1, well A7), min4 0.000783 (ip 223, exp 220, channel 2, well B4), min3 0.000873 (ip 223, exp 216, channel 1, well A4), min2 0.000814 (ip 201, exp 148, channel 1, well B3), min1 0.001120 (ip 223, exp 37, channel 2, well A2); to decrease, make sure suppress no up max 0.000527 (ip 223, exp 218, channel 1, well A4, not suppressed by other criteria)
    
    maxiter=500,
    maxfev=10000,
    model=l4,
    baselin='auto_median', # used: 'auto_lin', 'lin', 'parm'
    basecyc=3:6, # will be overwritten if (grepl('^auto_', baseline)). used: 15:20, 10:15, 3:6, 1:5 (gave poor baseline subtraction results for non-sigmoid shaped data when using 'lin')
    fallback='median', # used: 'auto_lin', 'lin', 'median'
    type='curve',
    # min_ac_max=0,
    # max_rsem=1.2, # used: 0.1
    # max_rser=0.3, # used: 0.025
    # max_cv_fluo_cq=0.41, # used: 0.41
    # min_nDmax_list=list(c(1280, 160), c(1953, -Inf)),
    # #                     single-       dual-
    # # before 128x    list(c(10, 1.25),  c(38.28, 2.73))
    
    before_128x=TRUE,
    
    extra_output=FALSE, 
    show_running_time=FALSE # option to show time cost to run this function
    ) {
    
    
    db_etc_out <- db_etc(
        db_usr, db_pwd, db_host, db_port, db_name, 
        exp_id, stage_id, calib_info)
    db_conn <- db_etc_out[['db_conn']]
    calib_info <- db_etc_out[['calib_info']]
    
    message('max_cycle: ', max_cycle)
    
    fd_qry <- sprintf(
        'SELECT * FROM fluorescence_data 
            LEFT JOIN ramps ON fluorescence_data.ramp_id = ramps.id
            INNER JOIN steps ON fluorescence_data.step_id = steps.id OR steps.id = ramps.next_step_id 
            WHERE fluorescence_data.experiment_id=%d AND steps.stage_id=%d
            ORDER BY well_num, cycle_num, channel',
        exp_id, stage_id)
    fluorescence_data <- dbGetQuery(db_conn, fd_qry)
    
    channels <- unique(fluorescence_data[,'channel'])
    names(channels) <- channels
    num_channels <- length(channels)
    
    if (num_channels == 1) dcv <- FALSE
    
    # for 128x
    if (before_128x) {
        min_fluomax <- min_fluomax / 128
        min_D1max <- min_D1max / 128
        min_D2max <- min_D2max / 128
        }
    
    amp_raw_list <- lapply(channels, get_amp_raw, db_conn, exp_id, stage_id, max_cycle, show_running_time)
    arl_ele1 <- amp_raw_list[[1]]
    
    # amp_raw_mtch <- process_mtch(
        # channels, 
        # matrix2array=TRUE, 
        # func=get_amp_raw, 
        # db_conn, 
        # exp_id, stage_id, 
        # # oc_data, 
        # max_cycle,
        # show_running_time)
    
    # get data out of `amp_calib_mtch`
    # amp_raw <- amp_raw_mtch[['post_consoli']][['fluo_cast']]
    # amp_raw_mtch_bych <- amp_raw_mtch[['pre_consoli']]
    # amp_calib_array <- amp_calib_mtch[['post_consoli']][['ac_mtx']]
    # aca_dim3 <- dim(amp_calib_array)[3]
    # rbbs <- amp_raw # right before baseline subtraction
    
    if (dcv) {
        # ac2dcv: when 1 %in% dim(amp_calib_array), `ac2dcv <- amp_calib_array[,,2:aca_dim3]` will result in reduced dimensions in ac2dcv
        aca_dim3 <- dim(arl_ele1)[2]
        ac2dcv_dim <- c(num_channels, dim(arl_ele1) - c(0,1))
        ac2dcv_dimnames <- list(channels, dimnames(arl_ele1)[[1]], dimnames(arl_ele1)[[2]][2:aca_dim3])
        ac2dcv <- array(NA, dim=ac2dcv_dim, dimnames=ac2dcv_dimnames)
        for (channel in channels) ac2dcv[channel,,] <- as.matrix(amp_raw_list[[channel]][,2:aca_dim3])
        # end: ac2dcv
        dcvd_out <- deconv(ac2dcv, db_conn, calib_info)
        rboc_mtch <- lapply(channels, function(channel) {
            dcvd_1ch <- dcvd_out[['dcvd_array']][channel,,]
            dcvd_1ch_wcyc <- cbind(amp_raw_list[[channel]][,1], dcvd_1ch)
            colnames(dcvd_1ch_wcyc)[1] <- 'cycle_num'
            return(dcvd_1ch_wcyc)
        })
        k_list_temp <- dcvd_out[['k_list_temp']]
    } else {
        rboc_mtch <- amp_raw_list
        k_list_temp <- NULL
    }
    
    oc_data <- prep_optic_calib(db_conn, calib_info, dye_in, dyes_2bfild)
    dbDisconnect(db_conn)
    
    rbbs <- lapply(channels, function(channel) {
        rboc_1ch <- as.matrix(rboc_mtch[[channel]])
        rbbs_1ch <- optic_calib(rboc_1ch[,2:ncol(rboc_1ch)], oc_data, channel)$fluo_calib
        colnames(rbbs_1ch)[1] <- 'cycle_num'
        return(rbbs_1ch)
    })
    
    num_cycles <- dim(arl_ele1)[1]
    
    if (num_cycles <= 2) {
        
        message(sprintf('Number of available cycles (%i) of fluorescence data is less than 2. Baseline subtraction and calculation of Cq and amplification efficiency are not performed.', num_cycles))
        
        num_wells <- aca_dim3 - 1
        well_names <- dimnames(arl_ele1)[[2]][2:aca_dim3]
        
        coefficients_1ch <- matrix(
            NA, 
            nrow = length(model[['parnames']]), 
            ncol = num_wells, 
            dimnames = list(model[['parnames']], well_names) )
        coefficients_mtch <- list()
        
        cq_eff_adj_1ch <- matrix(
            NA,
            nrow = 2, 
            ncol = num_wells, 
            dimnames = list(c('cq', 'eff'), well_names) )
        cq_eff_adj_mtch <- list()
        
        for (channel in channels) {
            coefficients_mtch[[as.character(channel)]] <- coefficients_1ch
            cq_eff_adj_mtch[[as.character(channel)]] <- cq_eff_adj_1ch
        }
        
        blsub_mtch_post <- list(
            'bl_corrected'=lapply(rbbs, function(ele) ele[,2:ncol(ele)]), 
            'coefficients'=coefficients_mtch)
        
        ce_mtch <- list('cq_eff_adj'=cq_eff_adj_mtch)
        
        maxq_blsub_fluo <- NA
    
    } else {
    
        if (min_reliable_cyc > num_cycles) mbf_cycles <- 1:num_cycles else mbf_cycles <- min_reliable_cyc:num_cycles # mbf = maxq_blsub_fluo
        
        blsub_mtch <- process_mtch(
            rbbs, 
            matrix2array=FALSE, 
            func=subtract_baseline, 
            maxiter, maxfev, 
            model, baselin, basecyc, fallback, 
            type, cp, 
            min_reliable_cyc, 
            show_running_time)
        blsub_mtch_pre <- blsub_mtch[['pre_consoli']]
        blsub_mtch_post <- blsub_mtch[['post_consoli']]
        
        blsub4ce <- lapply(blsub_mtch_pre, function(ele) list(
            'bl_corrected_mbf' = matrix( # `matrix` operation to ensure `bl_corrected_mbf` has two dimensions instead of one
                ele[['bl_corrected']][mbf_cycles,], 
                nrow=length(mbf_cycles), 
                dimnames = list(mbf_cycles, colnames(ele[['bl_corrected']])) ), 
            'mod_ori'=ele[['mod_ori']] ))
        mbf_fluos <- do.call(cbind, 
            lapply(1:length(blsub4ce), function (channel_i) blsub4ce[[channel_i]][['bl_corrected_mbf']]))
        maxq_blsub_fluo <- max(sapply(1:dim(mbf_fluos)[2], function(i) quantile(mbf_fluos[,i], qt_prob)))
        
        ce_mtch <- process_mtch(
            blsub4ce, 
            matrix2array=FALSE, 
            func=get_cq_eff, 
            num_cycles, 
            maxq_blsub_fluo, 
            type, cp, 
            min_reliable_cyc, 
            min_fluomax, 
            min_D1max, min_D2max, 
            min_fluo_ratio, 
            min_nD1max, min_nD2max 
            # max_cv_fluo_cq, 
            # max_rsem, max_rser # maximum residual standard error divided by absolute value of mean or range, for Cq to be reported as actual value instead of NA
            )[['post_consoli']]
    }
    
    downstream <- list('rbbs'=rbbs, 
                       'baseline_subtracted'=blsub_mtch_post[['bl_corrected']], 
                       'cq'=ce_mtch[['cq_eff_adj']], 
                       'coefficients'=blsub_mtch_post[['coefficients']]
                       )
    
    if (extra_output) {
        result_mtch <- c(
            downstream, blsub_mtch_post, ce_mtch, 
            list(
                'amp_raw_list'=amp_raw_list, 
                'dcvd_mtch'=rboc_mtch, 
                'k_list_temp'=k_list_temp, 
                'oc_data'=oc_data, 
                'maxq_blsub_fluo'=maxq_blsub_fluo) )
    } else result_mtch <- downstream
    
    check_obj2br(result_mtch)
    
    return(result_mtch)
    }


# function: get amplification data from MySQL database; perform water calibration.
get_amp_raw <- function(
    channel, # as 1st argument for iteration by channel
    db_conn, 
    exp_id, stage_id, # for selecting data to analyze
    # oc_data, # optical calibration data
    max_cycle, # number of cycles to analyze
    show_running_time # option to show time cost to run this function
    ) {
    
    # start counting for running time
    func_name <- 'get_amp_calib'
    start_time <- proc.time()[['elapsed']]
    
    message('get_amp_raw') # Xia Hong
    
    # get fluorescence data for amplification
    fluo_qry <- sprintf(
        'SELECT step_id, fluorescence_value, well_num, cycle_num, ramp_id, channel 
            FROM fluorescence_data 
            LEFT JOIN ramps ON fluorescence_data.ramp_id = ramps.id
            INNER JOIN steps ON fluorescence_data.step_id = steps.id OR steps.id = ramps.next_step_id 
            WHERE 
                fluorescence_data.experiment_id=%d AND 
                steps.stage_id=%d AND 
                fluorescence_data.channel=%d AND
                cycle_num <= %d
            ORDER BY well_num, cycle_num',
        exp_id, stage_id, as.numeric(channel), max_cycle)
    fluo_sel <- dbGetQuery(db_conn, fluo_qry)
    
    # cast fluo_sel into a pivot table organized by cycle_num (row label) and well_num (column label), average the data from all the available steps/ramps for each well and cycle
    fluo_mlt <- melt(
        fluo_sel, id.vars=c('step_id', 'well_num', 'cycle_num', 'ramp_id'), 
        measure.vars='fluorescence_value')
    fluo_cast <- dcast(fluo_mlt, cycle_num ~ well_num, mean)
    
    # get optical-calibrated data.
    num_wells <- length(unique(fluo_sel[,'well_num']))
    # calibd <- optic_calib(fluo_cast[,2:(num_wells+1)], oc_data, channel, show_running_time)$fluo_calib # column cycle_num is included, because adply automatically create a column at index 1 of output from rownames of input array (1st argument)
    # ac_mtx <- cbind(fluo_cast[, 'cycle_num'], calibd)
    # colnames(ac_mtx)[1] <- 'cycle_num'
    # amp_data <- list(
        # 'ac_mtx'=as.matrix(ac_mtx), # change data frame to matrix for ease of constructing array
        # 'fluo_cast'=fluo_cast, 
        # 'signal_water_diff'=calibd$signal_water_diff)
    
    # report time cost for this function
    end_time <- proc.time()[['elapsed']]
    if (show_running_time) message('`', func_name, '` took ', round(end_time - start_time, 2), ' seconds.')
    
    return(fluo_cast)
    }


# function: extract coefficients as a matrix from a modlist object
modlist_coef <- function(modLIST, model, coef_cols) {
    coef_list <- lapply(modLIST, 
        function(item) {
            coef_nas <- sapply(model[['parnames']], function(parname) parname=NA)
            if (is.na(item)) coefs <- coef_nas else coefs <- coef(item)
            if (is.null(coefs)) coefs <- coef_nas
            return(coefs) }) # coefficients of sigmoid-fitted models
    coef_mtx <- do.call(cbind, coef_list) # coefficients of sigmoid-fitted models
    colnames(coef_mtx) <- coef_cols
    return(coef_mtx)
    }


# function: baseline subtraction

subtract_baseline <- function(
    ac_mtx, 
    maxiter, maxfev, # control parameters for `nlsLM` in `pcrfit`. !!!! Note: `maxiter` sometimes affect finIter in a weird way: e.g. for the same well, finIter == 17 when maxiter == 200, finIter == 30 when maxiter == 30, finIter == 100 when maxiter == 100; maxiter affect fitting strategy?
    model, baselin, basecyc, fallback, # modlist parameters. 
    # baselin = c('none', 'mean', 'median', 'lin', 'quad', 'parm').
    # fallback = c('none', 'mean', 'median', 'lin', 'quad'). only valid when baselin = 'parm'
    type, cp, # getPar parameters
    min_reliable_cyc, 
    show_running_time # option to show time cost to run this function
    ) {
    
    num_cycles <- dim(ac_mtx)[1]
    
    # start counting for running time
    func_name <- 'subtract_baseline'
    start_time <- proc.time()[['elapsed']]
    
    control <<- nls.lm.control(maxiter=maxiter, maxfev=maxfev) # define as a global variable to be used in `nlsLM` in `pcrfit`. If not set, (maxiter = 1000, maxfev = 10000) will be used.
    
    # using customized modlist and baseline functions
    
    mod_R1 <- modlist(ac_mtx, model=model, baseline=baselin, basecyc=basecyc, min_reliable_cyc=min_reliable_cyc, fallback=fallback)
    mod_ori <- mod_R1[['ori']] # original output from qpcR function modlist
    well_names <- colnames(ac_mtx)[2:ncol(ac_mtx)]
    mod_ori_cm <- modlist_coef(mod_ori, model, well_names) # coefficients of sigmoid-fitted amplification curves
    
    if (baselin == 'parm') { # prepare output for baseline subtraction sigmoid fitting
      fluoa <- mod_R1[['fluoa']] # fluorecence with addition to ensure not all negative
      blmods <- mod_R1[['blmods']] # sigmoid models fitted during baseline subtraction thru 'parm'
      blmods_cm <- modlist_coef(blmods, model, well_names) # coefficients for sigmoid-fitted models fitted during baseline subtraction thru 'parm'
      fluo_blmods <- do.call(cbind, 
                             lapply(well_names, 
                                    function(well_name) 
                                      sapply(1:num_cycles, model$fct, blmods_cm[,well_name])))
      colnames(fluo_blmods) <- well_names
    } else {
      fluoa <- ac_mtx
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
    
    # report time cost for this function
    end_time <- proc.time()[['elapsed']]
    if (show_running_time) message('`', func_name, '` took ', round(end_time - start_time, 2), ' seconds.')
    
    return(list(
        'mod_ori'=mod_ori, 
        # 'bl_info'=bl_info, # removed for performance
        'fluoa'=fluoa, 'bl_coefs'=blmods_cm, 'fluo_blmods'=fluo_blmods, 
        'bl_corrected'=bl_corrected, 'coefficients'=mod_ori_cm
        # 'bl_normd'=bl_normd, 
        ))
    }


# function: get Cq and amplification efficiency values
get_cq_eff <- function(
    blsub_1ch, 
    num_cycles, 
    maxq_blsub_fluo, 
    # ac_mtx, 
    # signal_water_diff, 
    # min_ac_max, # the threshold which maximum (fluo value / scaling factor) of the well needs to exceed, for Cq to be reported as actual value instead of NA
    type, cp, 
    min_reliable_cyc, 
    # qt_prob, # quantile probability for maxq_blsub_fluo
    min_fluomax, 
    min_D1max, min_D2max, 
    min_fluo_ratio, 
    min_nD1max, min_nD2max 
    # max_cv_fluo_cq, 
    # max_rsem, max_rser # maximum residual standard error divided by absolute value of mean or range, for Cq to be reported as actual value instead of NA
    ) {
    
    # ac_maxs <- unlist(alply(ac_mtx, .margins=2, max))[2:ncol(ac_mtx)] / scaling_factor
    # ac_calib_ratios <- unlist(alply(ac_mtx, .margins=2, max))[2:ncol(ac_mtx)] / signal_water_diff
    # well_names <- colnames(ac_mtx)[2:ncol(ac_mtx)]
    
    bl_corrected_mbf <- blsub_1ch[['bl_corrected_mbf']]
    mod_ori <- blsub_1ch[['mod_ori']]
    
    well_names <- colnames(bl_corrected_mbf)
    num_wells <- length(well_names)
    
    cq_eff_raw <- getPar(mod_ori, type, cp, min_reliable_cyc=min_reliable_cyc)
    # rownames(cq_eff_raw) <- c('cq', 'eff')
    tagged_wellnames <- colnames(cq_eff_raw)
    colnames(cq_eff_raw) <- well_names
    
    cq_eff_adj <- cq_eff_raw[c('cq', 'eff'),]
    
    nD <- cq_eff_raw[c('D1max', 'D2max'),] / maxq_blsub_fluo
    rownames(nD) <- c('nD1max', 'nD2max')
    
    max_blsub_fluos <- c()
    fluo_ratios <- c()
    # rsems <- c()
    # rsers <- c()
    finIters <- c()
    fluo_cq_list <- list()
    cvs_fluo_cq <- c()
    adj_reasons <- list() # c() isn't pretty for view
    
    for (i in 1:num_wells) {
        
        # ac_max <- ac_maxs[i]
        # ac_calib_ratio <- ac_calib_ratios[i]
        
        mod <- mod_ori[[i]]
        stopCode <- mod$convInfo$stopCode
        coef_mod <- coef(mod)
        b <- coef_mod[['b']]
        
        max_blsub_fluo_i <- max(bl_corrected_mbf[,i])
        max_blsub_fluos[i] <- max_blsub_fluo_i
        fluo_ratio <- max_blsub_fluo_i / maxq_blsub_fluo
        fluo_ratios[i] <- fluo_ratio
        
        cer_i <- cq_eff_raw[,i]
        cq <- cer_i['cq']
        D1max <- cer_i['D1max']
        D2max <- cer_i['D2max']
        cpD1 <- cer_i['cpD1']
        cpD2 <- cer_i['cpD2']
        nD1max <- nD['nD1max', i]
        nD2max <- nD['nD2max', i]
        
        # rse <- tryCatch(sigma(mod), error=err_NA) # residual standard error of fitted amplification curve
        # if (length(rse) == 0) rse <- NA # class(mod) == 'pcrfit' instead of c('pcrfit', 'nls')
        # rsem <- rse / abs(mean(bl_corrected_mbf[,i])) # divided by absolute value of mean fluo over all cycles for each well
        # rsems[i] <- rsem
        # rser <- rse / diff(range(bl_corrected_mbf[,i])) # divided by fluo range over all cycles for each well
        # rsers[i] <- rser
        
        # `finIters[[i]]` <- NULL will not create element i for `finIters`
        finIter <- mod$convInfo$finIter
        if (is.null(finIter)) finIters[i] <- NA else finIters[i] <- finIter
        
        fluo_cq_list[[i]] <- c(NA, NA)
        cvs_fluo_cq[i] <- NA
        
        # if        (ac_max < min_ac_max) {
            # adj_reasons[[i]] <- paste('ac_max < min_ac_max. ac_max == ', ac_max, '. min_ac_max ==', min_ac_max, 
                                      # sep='')
        if        (is.null(b)) {
            adj_reasons[[i]] <- 'is.null(b)'
        } else if (b > 0) { # thought equivalent to downward curve, but found exp. 22 channel 1 well B2 in database '20160720_chaipcr_ip223' where upward log-phase starting very early and fitted curve b > 0
            adj_reasons[[i]] <- 'b > 0'
        
        # } else if (is.null(stopCode)) {
            # adj_reasons[[i]] <- 'is.null(stopCode)'
        # } else if (stopCode == -1) { # may not be accurate enough
            # adj_reasons[[i]] <- 'Number of iterations has reached `maxiter`'
        
        } else if (max_blsub_fluo_i < min_fluomax) {
            adj_reasons[[i]] <- sprintf('max bl_corrected fluo %f <= min_fluomax %f', max_blsub_fluo_i, min_fluomax)
        } else if (fluo_ratio < min_fluo_ratio) {
            adj_reasons[[i]] <- sprintf('fluo_ratio %f <= min_fluo_ratio %f', fluo_ratio, min_fluo_ratio)
        
        } else if (is.na(cq)) {
            adj_reasons[[i]] <- 'is.na(cq)'
        } else if (cq <= 0) { # Cy0
            adj_reasons[[i]] <- 'cq <= 0'
        } else if (cq == num_cycles) {
            adj_reasons[[i]] <- 'cq == num_cycles'
        } else if (cq > num_cycles) { # Cy0
            adj_reasons[[i]] <- 'cq > num_cycles'
        
        } else if (is.na(cpD1)) {
            adj_reasons[[i]] <- 'is.na(cpD1)'
        # } else if (is.na(cpD2)) {
            # adj_reasons[[i]] <- 'is.na(cpD2)'
        # } else if (cpD1 - 1 <= 0.01) {
            # adj_reasons[[i]] <- 'cpD1 - 1 <= 0.01'
        # } else if (cpD2 - 1 <= 0.01) {
            # adj_reasons[[i]] <- 'cpD2 - 1 <= 0.01'
        } else if (cq > cpD1 && cp == 'Cy0') { # fluo < 0 at `cpD1`, Cy0 will be invalid as Cq
            adj_reasons[[i]] <- 'cq > cpD1 && cp == Cy0'
        
        } else if (D1max < min_D1max) {
            adj_reasons[[i]] <- sprintf('D1max < min_D1max. D1max: %f. min_D1max: %f', D1max, min_D1max)
        } else if (D2max < min_D2max) {
            adj_reasons[[i]] <- sprintf('D2max < min_D2max. D2max: %f. min_D2max: %f', D2max, min_D2max)
        } else if (nD1max < min_nD1max) {
            adj_reasons[[i]] <- sprintf('nD1max < min_nD1max. nD1max: %f. min_nD1max: %f', nD1max, min_nD1max)
        } else if (nD2max < min_nD2max) {
            adj_reasons[[i]] <- sprintf('nD2max < min_nD2max. nD2max: %f. min_nD2max: %f', nD2max, min_nD2max)
        # # criterion based on residual standard error (rse) is disabled because non-flat baseline of real amplification violates sigmoid model and thus increase rse even when the curve is very smooth.
        # } else if (is.na(rse)) {
            # adj_reasons[[i]] <- 'error on sigma'
        # } else if (rsem > max_rsem & rser > max_rser) {
            # adj_reasons[[i]] <- sprintf('rsem > max_rsem & rser > max_rser. rsem == %f. max_rsem == %f. rser == %f. max_rser == %f. ', rsem, max_rsem, rser, max_rser)
        # } else {
            # # cv_fluo_cq
            # fluo_cq_actual <- blsub_fluo[floor(cq)] + (blsub_fluo[ceiling(cq)] - blsub_fluo[floor(cq)]) * (cq - floor(cq))
            # fluo_cq_predicted <- predict(mod, newdata=data.frame('Cycles'=cq))[1,1]
            # fluo_cq_vec <- c(fluo_cq_actual, fluo_cq_predicted)
            # fluo_cq_list[[i]] <- fluo_cq_vec
            # cv_fluo_cq <- sd(fluo_cq_vec) / mean(fluo_cq_vec)
            # cvs_fluo_cq[i] <- cv_fluo_cq
            
            # if (cv_fluo_cq > max_cv_fluo_cq) {
                # adj_reasons[[i]] <- sprintf(
                    # 'cv_fluo_cq > max_cv_fluo_cq. cv_fluo_cq == %f. max_cv_fluo_cq == %f.', 
                    # cv_fluo_cq, max_cv_fluo_cq) }
        } else {
            adj_reasons[[i]] <- 'none' }
        
        if (adj_reasons[[i]] != 'none') cq_eff_adj['cq', i] <- NA 
        
        } # end: for-loop
    
    # names(ac_maxs) <- well_names
    
    # names(rsems) <- well_names
    # names(rsers) <- well_names
    names(finIters) <- well_names
    names(cvs_fluo_cq) <- well_names
    names(adj_reasons) <- well_names
    
    fluos_cq <- do.call(cbind, fluo_cq_list)
    rownames(fluos_cq) <- c('actual', 'predicted')
    colnames(fluos_cq) <- well_names
    
    return(list('cq_eff_adj'=cq_eff_adj, 
                # 'ac_maxs'=ac_maxs, 
                'max_blsub_fluos'=max_blsub_fluos, 'fluo_ratios'=fluo_ratios, 'cq_eff_raw'=cq_eff_raw, 'nD'=nD, 
                # 'rsems'=rsems, 'rsers'=rsers, 
                'finIters'=finIters, 'fluos_cq'=fluos_cq, 'cvs_fluo_cq'=cvs_fluo_cq, 'adj_reasons'=adj_reasons, # for debugging
                'tagged_wellnames'=tagged_wellnames
                ))
    }




