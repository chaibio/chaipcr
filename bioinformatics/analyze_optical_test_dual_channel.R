# chaipcr/web/public/dynexp/optical_test_dual_channel/analyze.R


library(jsonlite)


# constants

num_channels = 2 # channel indice are numeric

FAM_MTMAX_1MAX_1MIN_1MAX = 0.7
FAM_MTMIN_1MIN_2MAX_1MIN = 0.09
HEX_MTMAX_2MAX_2MIN_2MAX = 0.7
HEX_MTMIN_2MIN_1MAX_2MIN = 0.3
WATER_MAX = c(35000, 6000) # channel 1, channel 2


analyze_optical_test_dual_channel <- function(
    db_usr, db_pwd, db_host, db_port, db_name, 
    exp_id, calib_info
    ) {
    
    
    db_etc_out <- db_etc(
        db_usr, db_pwd, db_host, db_port, db_name, 
        exp_id, stage_id=NULL, calib_info)
    db_conn <- db_etc_out[['db_conn']]
    
    fluo_qry <- sprintf(
        'SELECT step_id, well_num, fluorescence_value, channel
            FROM fluorescence_data
            WHERE experiment_id=%i AND cycle_num=1
            ORDER BY well_num, channel', 
        exp_id)
    fluo_data <- dbGetQuery(db_conn, fluo_qry)
    
    num_wells <- length(unique(fluo_data[,'well_num']))
    
    step_labels <- c('baseline', 'channel_1', 'channel_2', 'water')
    
    fluo_list <- lapply(
        step_labels,
        function(step_label) do.call(rbind, lapply(
                1:num_channels, 
                function(channel) fluo_data[
                      fluo_data[,'step_id'] == calib_info[[step_label]][['step_id']]
                    & fluo_data[,'channel'] == channel, 
                    'fluorescence_value'] )))
    
    names(fluo_list) <- step_labels
    
    
    FAM_1max <- max(fluo_list[['channel_1']][1,])
    FAM_1min <- min(fluo_list[['channel_1']][1,])
    FAM_2max <- max(fluo_list[['channel_1']][2,])
    HEX_2max <- max(fluo_list[['channel_2']][2,])
    HEX_2min <- min(fluo_list[['channel_2']][2,])
    HEX_1max <- max(fluo_list[['channel_2']][1,])
    
    dye_list <<- list(
        'channel_1' = (
               (FAM_1max - FAM_1min) / FAM_1max < FAM_MTMAX_1MAX_1MIN_1MAX
            && (FAM_1min - FAM_2max) / FAM_1min > FAM_MTMIN_1MIN_2MAX_1MIN ),
        'channel_2' = (
               (HEX_2max - HEX_2min) / HEX_2max < HEX_MTMAX_2MAX_2MIN_2MAX
            && (HEX_2min - HEX_1max) / HEX_2min > HEX_MTMIN_2MIN_1MAX_2MIN ) )
    
    
    bool_list <- list()
    bool_mtx_dim <- c(num_channels, num_wells)
    
    bool_list[['baseline']] <- array(TRUE, dim=bool_mtx_dim)
    
    bool_list[['water']] <- do.call(rbind, lapply(
        1:num_channels, 
        function(channel) fluo_list[['water']][channel,] < WATER_MAX[channel] ))
    
    for (step_label in c('channel_1', 'channel_2')) {
        bool_list[[step_label]] <- array(dye_list[[step_label]], dim=bool_mtx_dim) }
    
    names(step_labels) <- c('baseline', 'FAM', 'HEX', 'water')
    results <- lapply(
        1:num_wells, 
        function(well_i) lapply(
            step_labels, 
            function(step_label) lapply(
                1:num_channels, 
                function(channel) list(
                    unbox(fluo_list[[step_label]][channel, well_i]),
                    unbox(bool_list[[step_label]][channel, well_i]) ) )))
    
    
    return(toJSON(list('optical_data' = results)))
    
    }




