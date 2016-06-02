# chaipcr/web/public/dynexp/optical_test_dual_channel/analyze.R

library(jsonlite)

# constants
FAM_MTMAX_1MAX_1MIN_1MAX = 0.7
FAM_MTMIN_1MIN_2MAX_1MIN = 0.09
HEX_MTMAX_2MAX_2MIN_2MAX = 0.7
HEX_MTMIN_2MIN_1MAX_2MIN = 0.3
WATER_MAX_1 = 35000
WATER_MAX_2 = 6000


analyze_optical_test_dual_channel <- function(
    db_usr, db_pwd, db_host, db_port, db_name, 
    exp_id, calib_info
    ) {
    
    db_etc_out <- db_etc(
        db_usr, db_pwd, db_host, db_port, db_name, 
        exp_id, stage_id=NULL, calib_info)
    db_conn <- db_etc_out[['db_conn']]
    
    fluo_qry <- sprintf(
        'SELECT step_id, fluorescence_value, channel
            FROM fluorescence_data
            WHERE experiment_id=%i AND cycle_num=1
            ORDER BY well_num, channel', 
        exp_id)
    fluo_data <- dbGetQuery(db_conn, fluo_qry)
    
    step_labels <- c('channel_1', 'channel_2', 'water')
    
    ot_list <- lapply(
        step_labels,
        function(step_label) lapply(
                1:2, 
                function(channel) fluo_data[
                      fluo_data[,'step_id'] == calib_info[[step_label]][['step_id']]
                    & fluo_data[,'channel'] == channel, 
                    'fluorescence_value']))
    
    names(ot_list) <- step_labels
    
    FAM_1max <- max(ot_list[['channel_1']][[1]])
    FAM_1min <- min(ot_list[['channel_1']][[1]])
    FAM_2max <- max(ot_list[['channel_1']][[2]])
    HEX_2max <- max(ot_list[['channel_2']][[2]])
    HEX_2min <- min(ot_list[['channel_2']][[2]])
    HEX_1max <- max(ot_list[['channel_2']][[1]])
    
    results <- list(
        'FAM' = unbox(
               (FAM_1max - FAM_1min) / FAM_1max < FAM_MTMAX_1MAX_1MIN_1MAX
            && (FAM_1min - FAM_2max) / FAM_1min > FAM_MTMIN_1MIN_2MAX_1MIN ),
        'HEX' = unbox(
               (HEX_2max - HEX_2min) / HEX_2max < HEX_MTMAX_2MAX_2MIN_2MAX
            && (HEX_2min - HEX_1max) / HEX_2min > HEX_MTMIN_2MIN_1MAX_2MIN ),
        'water' = sapply(1:length(ot_list[['water']][[1]]), function(well_i) { # assuming [[1]] and [[2]] of ot_list[['water']] have the same number of elements (number of wells)
               ot_list[['water']][[1]][well_i] < WATER_MAX_1 && ot_list[['water']][[2]][well_i] < WATER_MAX_2 }))
    
    return(toJSON(results))
    }




