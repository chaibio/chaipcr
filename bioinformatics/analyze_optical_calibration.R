# chaipcr/web/public/dynexp/optical_cal/analyze.R
# use `prep_calib` to check validity of water calibration data

library(jsonlite)

check_optic_calib <- function(channel, db_conn, calib_exp_id, verbose) {
    
    result1 <- tryCatch(prep_optic_calib(db_conn, calib_exp_id, channel, verbose), error=function(e) e)
    
    if ('error' %in% class(result1)) {
        valid <- FALSE
        #err <- 'Fluorescein calibrator was less fluorescent than water in some wells. Please retry with new fluorescein calibrator.' # solution 1
        err_msg <- result1$message # solution 2 as string
        err_details <- as.character(result1)
    } else {
        valid <- TRUE
        err_msg <- NULL
        err_details <- NULL }
    
    result2 <- list('valid'=valid, 'error_message'=err_msg, 'error_details'=err_details)
    
    return(result2)
    #return(toJSON(result2))
    }


analyze_optical_calibration <- function(
    db_usr, db_pwd, db_host, db_port, db_name, 
    calib_exp_id, 
    calib_id=NULL, # not used
    verbose=FALSE, 
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
                                 db_conn, calib_exp_id, verbose)[['post_consoli']]
    result <- lapply(result_lists, 
                     function(out_ele) paste(sapply(channels, 
                                                    function(channel) paste('Channel ', channel, '. ', out_ele[[channel]],
                                                                            sep='')), 
                                                                            collapse='\n'))
    result[['valid']] <- all(unlist(result_lists[['valid']]))
    
    if (out_json) result <- toJSON(result)
    
    return(result)
}

