# chaipcr/web/public/dynexp/optical_cal/analyze.R
# use `prep_calib` to check validity of water calibration data

library(jsonlite)

check_optic_calib <- function(channel, db_conn, calib_exp_id) {
    
    result1 <- tryCatch(prep_optic_calib(db_conn, calib_exp_id, channel), error=function(e) e)
    
    if ('error' %in% class(result1)) {
        valid <- FALSE
        #err <- 'Fluorescein calibrator was less fluorescent than water in some wells. Please retry with new fluorescein calibrator.' # solution 1
        error_message <- paste('Invalid calibration in Channel ', channel, ', ', 
                               strsplit(result1$message, 'Details: ')[[1]][1], 
                               sep='')
        error_details <- paste('Channel ', channel, '. ', 
                             as.character(result1), 
                             sep='')
    } else {
        valid <- TRUE
        error_message <- NULL
        error_details <- NULL }
    
    result2 <- list('valid'=valid, 'error_message'=error_message, 'error_details'=error_details)
    
    return(result2)
    #return(toJSON(result2))
    }


analyze_optical_calibration <- function(
    db_usr, db_pwd, db_host, db_port, db_name, 
    calib_exp_id, 
    calib_id=NULL, # not used
    out_json=TRUE) 
{
    db_conn <- db_etc(db_usr, db_pwd, db_host, db_port, db_name, 
                      calib_exp_id, stage_id=NULL, calib_id)
    
    calib_exp_qry <-  sprintf('SELECT channel 
                               FROM fluorescence_data 
                               WHERE experiment_id=%d', 
                               calib_exp_id)
    calib_exp_data <- dbGetQuery(db_conn, calib_exp_qry)
    
    channels <- unique(calib_exp_data[,'channel'])
    names(channels) <- channels
    
    result_lists <- process_mtch(channels, 
                                 matrix2array=FALSE, # doesn't matter because no original output was matrix
                                 func=check_optic_calib, 
                                 db_conn, calib_exp_id)[['post_consoli']]
    
    valid <- all(unlist(result_lists[['valid']]))
    if (valid) {
        error_message <- NULL
        error_details <- NULL
    } else {
        error_message <- paste(unlist(result_lists[['error_message']]), collapse='')
        error_details <- paste(unlist(result_lists[['error_details']]), collapse='\n') }
    
    result <- list('valid'=valid, 'error_message'=error_message, 'error_details'=error_details)
    
    if (out_json) result <- toJSON(result)
    
    return(result)
}

