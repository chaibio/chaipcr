# chaipcr/web/public/dynexp/optical_cal/analyze.R
# use `prep_calib` to check validity of water calibration data

library(jsonlite)

check_optic_calib <- function(channel, db_conn, exp_id, verbose) {
    
    result1 <- tryCatch(prep_optic_calib(db_conn, exp_id, channel, verbose), error=function(e) e)
    
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
    exp_id, 
    calib_id=NULL, # not used
    channels=c(1,2), 
    verbose=FALSE, 
    out_json=TRUE) 
{
    db_conn <- db_etc(db_usr, db_pwd, db_host, db_port, db_name, 
                      exp_id, stage_id=NULL, calib_id)
    
    names(channels) <- channels
    
    result <- process_mtch(channels, check_optic_calib, db_conn, exp_id, verbose)
    
    if (out_json) result <- toJSON(result)
    
    return(result[['post_consoli']])
}

