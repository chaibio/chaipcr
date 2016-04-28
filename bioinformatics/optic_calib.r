# calib

# old default: step ids for calibration data
oc_water_step_id <- 2
oc_signal_step_ids <- c('1'=4, '2'=4)

# # default: preset calibration experiment(s) # not set up yet
# preset_calib_id <- 1
# dye2chst <- list( # mapping from dye to channel and step_id.
                 # 'FAM'=c('channel'=1, 'step_id'=4), 
                 # 'HEX'=c('channel'=2, 'step_id'=6), 
                 # 'JOE'=c('channel'=2, 'step_id'=8)
                 # )


{ # for testing: 'test_pc1.r' 'amp_2ch' option 26

{ # pre-heating

# # db_name_ <- '20160328_chaipcr'

# # filter not pre-heated
# # calib_id_ <- list('water'=76, 'signal'=c('1'=77, '2'=78))
# oc_water_step_id <- 177
# oc_signal_step_ids <- c('1'=178, '2'=179)

# # 60C pre-heated filter
# # calib_id_ <- list('water'=79, 'signal'=c('1'=81, '2'=80))
# oc_water_step_id <- 182
# oc_signal_step_ids <- c('1'=186, '2'=184)

# # 80C pre-heated filter
# # calib_id_ <- list('water'=84, 'signal'=c('1'=86, '2'=85))
# oc_water_step_id <- 193
# oc_signal_step_ids <- c('1'=197, '2'=195)

} # end: pre-heating


{ # dyes

# db_name_ <- '20160406_chaipcr'

{ # FAM, HEX

# # 0.1 ml new factory. FAM 115, HEX 116.
# # calib_id_ <- list('water'=114, 'signal'=c('1'=115, '2'=116))
# oc_water_step_id <- 264
# oc_signal_step_ids <- c('1'=266, '2'=268)

# # 0.2 ml. FAM 119, HEX 120.
# # calib_id_ <- list('water'=118, 'signal'=c('1'=119, '2'=120))
# oc_water_step_id <- 272
# oc_signal_step_ids <- c('1'=274, '2'=276)

# # 0.1 ml new user. FAM 123, HEX 124.
# # calib_id_ <- list('water'=122, 'signal'=c('1'=123, '2'=124))
# oc_water_step_id <- 280
# oc_signal_step_ids <- c('1'=282, '2'=284)
}

{ # FAM, JOE

# # 0.1 ml new factory. FAM 115, JOE 117.
# # calib_id_ <- list('water'=114, 'signal'=c('1'=115, '2'=117))
# oc_water_step_id <- 264
# oc_signal_step_ids <- c('1'=266, '2'=270)

# # 0.2 ml. FAM 119, JOE 121.
# # calib_id_ <- list('water'=118, 'signal'=c('1'=119, '2'=121))
# oc_water_step_id <- 272
# oc_signal_step_ids <- c('1'=274, '2'=278)

# # 0.1 ml new user. FAM 123, JOE 125.
# # calib_id_ <- list('water'=122, 'signal'=c('1'=123, '2'=125))
# oc_water_step_id <- 280
# oc_signal_step_ids <- c('1'=282, '2'=286)
}

} # end: dyes


{ # mapping from factory to user dye data

# db_name_ <- '20160406_chaipcr'

preset_calib_ids <- list('water'=114, 
                         'signal'=c('FAM'=115, 'HEX'=116, 'JOE'=117))
dye2chst <- list( # mapping from dye to channel and step_id.
                 'FAM'=c('channel'=1, 'step_id'=266), 
                 'HEX'=c('channel'=2, 'step_id'=268), 
                 'JOE'=c('channel'=2, 'step_id'=270)
                 )

# # 0.1 ml new user. FAM 123.
# # calib_id_ <- list('water'=122, 'signal'=c('1'=123))
# oc_water_step_id <- 280
# oc_signal_step_ids <- c('1'=282)

}


} # end: for testing


# process preset calibration data
dye2chst_channels <- unique(sapply(dye2chst, function(ele) ele['channel']))
dye2chst_ccsl <- list('set'=dye2chst_channels, 'description'='all channels in the preset calibration data') # ccsl=channels_check_subset_list


# function: check subset
check_subset <- function(list_small, list_big) {
    if (!all(list_small[['set']] %in% list_big[['set']])) {
        stop(sprintf('%s is not a subset of %s.', list_small[['description']], list_big[['description']])) }
    }


# function: get calibration data
get_calib_data <- function(calib_id_s, step_id_s, 
                           db_conn, 
                           calib_id_name_type=c('dye', 'channel')) {
    
    if (length(calib_id_s) == 1 && length(unique(step_id_s)) == 1) {
        calib_id <- calib_id_s
        step_id <- unique(step_id_s)
        calib_qry <-  sprintf('SELECT fluorescence_value, well_num, channel
                                   FROM fluorescence_data 
                                   WHERE     experiment_id=%d 
                                         AND step_id=%d 
                                         AND cycle_num=1
                                   ORDER BY well_num', 
                                   calib_id, 
                                   step_id)
        calib_df <- dbGetQuery(db_conn, calib_qry)
        channels_in_df <- as.character(unique(calib_df[,'channel']))
        well_names <- unique(calib_df[,'well_num'])
        calib_list <- lapply(channels_in_df, 
                             function(channel_in_df) {
                                 calib_vec <- c(calib_df[calib_df[,'channel'] == channel_in_df, 'fluorescence_value']) # Subsetting both row and column of a data frame results to make one of the dimension equal 1 results in a vector instead of a data frame; but subsetting only row or only column to make one of the dimension equal 1 results in a data frame. `c()` is to explicitly ensure output to be a vector, though input is already a vector.
                                 names(calib_vec) <- well_names
                                 return(calib_vec) } )
        names(calib_list) <- channels_in_df
    
    } else if (length(calib_id_s) > 1 || length(unique(step_id_s)) > 1) { # for testing with different experiments for calibration
        
        if (length(calib_id_s) == 1 && length(unique(step_id_s)) > 1) {
            calib_id_s <- rep(calib_id_s, times=length(step_id_s))
            names(calib_id_s) <- names(step_id_s) }
        
        calib_list <- lapply(names(calib_id_s), function(name_calib_id) {
            channel <- switch(calib_id_name_type, 'dye'=dye2chst[[name_calib_id]]['channel'], 'channel'=name_calib_id)
            # message('calib_id_s[name_calib_id] :', calib_id_s[name_calib_id])
            # message('step_id_s[name_calib_id] :', step_id_s[name_calib_id])
            # message('as.numeric(channel) :', as.numeric(channel))
            calib_qry <- sprintf('SELECT fluorescence_value, well_num 
                                     FROM fluorescence_data 
                                     WHERE     experiment_id=%d 
                                           AND step_id=%d 
                                           AND channel=%d 
                                           AND cycle_num=1
                                     ORDER BY well_num', 
                                     calib_id_s[name_calib_id], 
                                     step_id_s[name_calib_id], 
                                     as.numeric(channel))
            calib_df <- dbGetQuery(db_conn, calib_qry)
            well_names <- unique(calib_df[,'well_num'])
            calib_vec <- c(calib_df[,'fluorescence_value']) # `c()` is to transform col_df into a vector
            names(calib_vec) <- well_names
            return(calib_vec) } )
        
        names(calib_list) <- names(calib_id_s) }
    
    return(calib_list)
    }


# function: check whether the data in optical calibration experiment is valid; if yes, prepare calibration data

prep_optic_calib <- function(db_conn, calib_id_s, dye_in='FAM', dyes_2bfild=NULL) {
    
    length_calib_id_s <- length(calib_id_s)
    if (length_calib_id_s == 1) { # `calib_id_s` is an integer
        water_calib_id <- calib_id_s
        signal_calib_id_s <- calib_id_s
    } else { # calib_id_s is a list with > 1 elements
        calib_id_s_names <- names(calib_id_s)
        if (calib_id_s_names[2] == 'signal') { # xqrm format
            water_calib_id <- calib_id_s[['water']]
            signal_calib_id_s <- calib_id_s[['signal']] 
        } else { # chai format: "list(water=list(calibration_id=..., step_id=...), channel_1=list(calibration_id=..., step_id=...), channel_2=list(calibration_id=...", step_id=...)"
            water_cs_list <- calib_id_s[['water']]
            water_calib_id <- water_cs_list[['calibration_id']]
            oc_water_step_id <- water_cs_list[['step_id']]
            ci_channel_is <- calib_id_s_names[2:length_calib_id_s]
            names(ci_channel_is) <- sapply(calib_id_s_names[2:length_calib_id_s], 
                                           function(calib_id_s_name) strsplit(calib_id_s_name, split='_')[[1]][2])
            signal_calib_id_s  <- sapply(ci_channel_is, 
                                         function(ci_channel_i) calib_id_s[[ci_channel_i]][['calibration_id']])
            oc_signal_step_ids <- sapply(ci_channel_is, 
                                         function(ci_channel_i) calib_id_s[[ci_channel_i]][['step_id']]) }}
    
    calib_water_list <- get_calib_data(water_calib_id, oc_water_step_id, db_conn, NULL)
    channels_in_water <- names(calib_water_list)
    check_subset(list('set'=channels_in_water, 'description'='Input water channels'), dye2chst_ccsl)
    names(channels_in_water) <- channels_in_water
    
    calib_signal_list <- get_calib_data(signal_calib_id_s, oc_signal_step_ids, db_conn, 'channel')
    channels_in_signal <- names(calib_signal_list)
    check_subset(list('set'=channels_in_signal, 'description'='Input signal channels'), dye2chst_ccsl)
    names(channels_in_signal) <- channels_in_signal
    
    
    # check data length
    water_lengths <- sapply(calib_water_list, length)
    signal_lengths <- sapply(calib_signal_list, length)
    if (length(unique(c(water_lengths, signal_lengths))) > 1) {
        stop(sprintf('data length not equal across all the channels and/or between water and signal. water: %s. signal: %s', paste(water_lengths, collapse=', '), paste(signal_lengths, collapse=', '))) }
    
    # check whether signal > water
    well_names <- names(calib_water_list[[1]])
    stop_msgs <- c()
    for (channel_in_signal in channels_in_signal) {
        calib_invalid_vec <- (calib_signal_list[[channel_in_signal]] - calib_water_list[[channel_in_signal]] <= 0)
        if (any(calib_invalid_vec)) {
            ci_well_nums_str <- paste(paste(well_names[calib_invalid_vec], collapse=', '), '. ', sep='')
            stop_msgs[channel_in_signal] <- paste(
                                                  sprintf('Invalid calibration data in channel %s: ', channel_in_signal), 
                                                  'fluorescence value of water is greater than or equal to that of dye in the following well(s) - ', ci_well_nums_str, 
                                                  sep='')
            } }
    if (length(stop_msgs) > 0) {
        stop(paste(stop_msgs, collapse='\n')) }
    
    if (length(dyes_2bfild) > 0) { # extrapolate calibration data for missing channels
        
        message('Preset calibration data is used to extrapolate calibration data for missing channels.')
        
        channels_missing <- setdiff(channels_in_water, channels_in_signal)
        dyes_2bfild_channels <- sapply(dyes_2bfild, function(dye) dye2chst[[dye]]['channel'])
        check_subset(list('set'=channels_missing, 'description'='Channels missing calibration data'), 
                     list('set'=dyes_2bfild_channels, 'description'='channels corresponding to the dyes of which calibration data is needed'))
        
        # process preset calibration data
        preset_step_ids <- sapply(dye2chst, function(ele) ele['step_id'])
        names(preset_step_ids) <- names(dye2chst)
        preset_calib_signal_list <- get_calib_data(preset_calib_ids[['signal']], 
                                                   preset_step_ids, 
                                                   db_conn, 
                                                   'dye')
        
        pivot_preset <- preset_calib_signal_list[[dye_in]]
        pivot_in <- calib_signal_list[[dye2chst[[dye_in]]['channel']]]
        
        in2preset <- pivot_in / pivot_preset
        
        for (dye_2bfild in dyes_2bfild) {
            calib_signal_list[[dye2chst[[dye_2bfild]]['channel']]] <- preset_calib_signal_list[[dye_2bfild]] * in2preset }
        }
    
    oc_data <- lapply(list('water'=calib_water_list, 
                           'signal'=calib_signal_list), 
                      function(ele) { calib_mtx <- do.call(rbind, ele)
                                      rownames(calib_mtx) <- names(ele)
                                      return(calib_mtx) } )
    
    return(oc_data)
}


# function: perform optical (water) calibration on fluo

optic_calib <- function(fluo, oc_data, channel, show_running_time=FALSE) {
    
    # start counting for running time
    func_name <- 'calib'
    start_time <- proc.time()[['elapsed']]
    
    # perform calibration
    oc_water <- oc_data[['water']][as.character(channel),]
    oc_signal <- oc_data[['signal']][as.character(channel),]
    signal_water_diff <- oc_signal - oc_water
    swd_normd <- signal_water_diff / mean(signal_water_diff)
    fluo_calib <- adply(fluo, .margins=1, 
                        function(row1) scaling_factor_optic_calib * (row1 - oc_water) / swd_normd) # adply automatically create a column at index 1 of output from rownames of input array (1st argument)
    
    # report time cost for this function
    end_time <- proc.time()[['elapsed']]
    if (show_running_time) message('`', func_name, '` took ', round(end_time - start_time, 2), ' seconds.')
    
    return(list('fluo_calib'=fluo_calib, 
                'signal_water_diff' = scaling_factor_optic_calib * swd_normd))
}



################## old


# # function: check whether the data in optical calibration experiment is valid; if yes, prepare calibration data

# prep_optic_calib <- function(db_conn, calib_id, channel) {
    
    # if (length(calib_id) == 1) {
        # water_calib_id <- calib_id
        # signal_calib_id <- calib_id
    # } else if (length(calib_id) == 2) { # for testing with different experiments for calibration
        # water_calib_id <- calib_id[['water']]
        # signal_calib_id <- calib_id[['signal']][as.character(channel)] }
    
    # calib_water_qry <-  sprintf('SELECT fluorescence_value, well_num 
                                    # FROM fluorescence_data 
                                    # WHERE experiment_id=%d AND step_id=%d AND channel=%d AND cycle_num=1
                                    # ORDER BY well_num', 
                                    # water_calib_id, oc_water_step_id, as.numeric(channel))
    # calib_signal_qry <- sprintf('SELECT fluorescence_value, well_num 
                                    # FROM fluorescence_data 
                                    # WHERE experiment_id=%d AND step_id=%d AND channel=%d AND cycle_num=1
                                    # ORDER BY well_num', 
                                    # signal_calib_id, oc_signal_step_ids[as.character(channel)], as.numeric(channel))
    
    # calib_water  <- dbGetQuery(db_conn, calib_water_qry)
    # calib_signal <- dbGetQuery(db_conn, calib_signal_qry)
    
    # dw <- dim(calib_water)
    # ds <- dim(calib_signal)
    
    # well_nums <- calib_water[,'well_num']
    
    # if (!(all(dw == ds))) {
        # stop(sprintf('dimensions of water and signal wells for calibration are not equal: calib_water(%i,%i) while calib_signal(%i,%i)', 
                     # dw[1], dw[2], ds[1], ds[2])) }
    
    # calib_water_fluo <- t(calib_water[,'fluorescence_value'])
    # calib_signal_fluo <- t(calib_signal[,'fluorescence_value'])
    
    # calib_invalid_vec <- (calib_signal_fluo - calib_water_fluo <= 0)
    # if (any(calib_invalid_vec)) {
        # ci_well_nums_str <- paste(paste(well_nums[calib_invalid_vec], collapse=', '), '. ', sep='')
        # stop(paste('fluorescence value of water is greater than that of dye in the following well(s) - ', ci_well_nums_str, 
                   # 'Details: ',
                       # 'Invalid calibration. ', 
                       # 'Please perform a new optical calibration experiment. ', 
                   # sep='')
             # ) }
    
    # return(list('num_calib_wells'=dw[1], 
                # 'calib_water_fluo'=calib_water_fluo, 
                # 'calib_signal_fluo'=calib_signal_fluo))
# }


# # function: perform optical (water) calibration on fluo

# optic_calib <- function(fluo, db_conn, calib_id, channel, show_running_time=FALSE) {
    
    # # start counting for running time
    # func_name <- 'calib'
    # start_time <- proc.time()[['elapsed']]
    
    # calib_data <- prep_optic_calib(db_conn, calib_id, channel)
    
    # if (!(calib_data$num_calib_wells == num_wells)) {
        # stop('number of calibration wells (', 
             # calib_data$num_calib_wells, 
             # ') is not equal to user-defined number of wells (', 
             # num_wells, 
             # ').') }
    
    # # perform calibration
    # signal_water_diff <<- calib_data$calib_signal_fluo - calib_data$calib_water_fluo
    # swd_normd <<- signal_water_diff / mean(signal_water_diff)
    # fluo_calib <- adply(fluo, .margins=1, 
                        # function(row1) scaling_factor_optic_calib * (row1 - calib_data$calib_water_fluo) / swd_normd) # adply automatically create a column at index 1 of output from rownames of input array (1st argument)
    
    # # report time cost for this function
    # end_time <- proc.time()[['elapsed']]
    # if (show_running_time) message('`', func_name, '` took ', round(end_time - start_time, 2), ' seconds.')
    
    # return(list('fluo_calib'=fluo_calib, 
                # 'signal_water_diff' = scaling_factor_optic_calib * swd_normd))
# }


