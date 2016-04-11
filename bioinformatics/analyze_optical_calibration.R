# chaipcr/web/public/dynexp/optical_cal/analyze.R
# use `prep_calib` to check validity of water calibration data

library(jsonlite)

analyze_optical_calibration <- function(
    db_usr, db_pwd, db_host, db_port, db_name, 
    calib_exp_id, 
    calib_id=NULL, # not used
    dye_in='FAM', dyes_2bfild=NULL, 
    out_json=TRUE) 
{
    db_conn <- db_etc(db_usr, db_pwd, db_host, db_port, db_name, 
                      calib_exp_id, stage_id=NULL, calib_id)
    
    result1 <- tryCatch(prep_optic_calib(db_conn, calib_exp_id, dye_in, dyes_2bfild), error=function(e) e)
    
    if ('error' %in% class(result1)) {
        valid <- FALSE
        #err <- 'Fluorescein calibrator was less fluorescent than water in some wells. Please retry with new fluorescein calibrator.' # solution 1
        error_message <- strsplit(result1$message, 'Details: ')[[1]][1]
        error_details <- as.character(result1)
    } else {
        valid <- TRUE
        error_message <- NULL
        error_details <- NULL }
    
    result2 <- list('valid'=valid, 'error_message'=error_message, 'error_details'=error_details)
    
    if (out_json) result2 <- toJSON(result2)
    
    return(result2)
}

