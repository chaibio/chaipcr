# chaipcr/web/public/dynexp/optical_cal/analyze.R
# use `prep_calib` to check validity of water calibration data

library(jsonlite)

analyze_optical_calibration <- function(
    db_usr, db_pwd, db_host, db_port, db_name, 
    calib_exp_id, # not used for computation
    calib_info, # really used
    dye_in='FAM', dyes_2bfild=NULL, 
    out_json=TRUE) 
{
    ci_valid <- tryCatch(calib_info, error=err_e)
    if ('error' %in% class(ci_valid)) stop('Calibration info is not valid.')
    
    db_etc_out <- db_etc(
        db_usr, db_pwd, db_host, db_port, db_name, 
        calib_exp_id, stage_id=NULL, calib_info)
    db_conn <- db_etc_out[['db_conn']]
    
    valid <- TRUE
    err_msg_vec <- c()
    err_dtls_vec <- c()
    
    if (inherits(calib_info, 'list') && length(calib_info) >= 3) { # dual channel
        result_k <- get_k(db_conn, calib_info, well_proc='dim3')
        if (nchar(result_k[['k_singular']]) > 0) {
            valid <- FALSE
            #err <- 'Fluorescein calibrator was less fluorescent than water in some wells. Please retry with new fluorescein calibrator.' # solution 1
            err_msg_vec <- c(err_msg_vec, result_k[['k_singular']])
            err_dtls_vec <- c(err_dtls_vec, result_k[['k_singular']])
        }
    }
    
    result_oc <- tryCatch(prep_optic_calib(db_conn, calib_info, dye_in, dyes_2bfild), error=function(e) e)
    if ('error' %in% class(result_oc)) {
        valid <- FALSE
        #err <- 'Fluorescein calibrator was less fluorescent than water in some wells. Please retry with new fluorescein calibrator.' # solution 1
        err_msg_vec <- c(err_msg_vec, strsplit(result_oc$message, 'Details: ')[[1]][1])
        err_dtls_vec <- c(err_dtls_vec, as.character(result_oc))
    }
    
    dbDisconnect(db_conn)
    
    error_message <- paste(err_msg_vec, collapse='')
    error_details <- paste(err_dtls_vec, collapse='')
    
    if (nchar(error_message) == 0) error_message <- NULL
    if (nchar(error_details) == 0) error_details <- NULL
    
    result2 <- list(
        'valid'=valid, 
        'error_message'=error_message, 
        'error_details'=error_details
    )
    
    if (out_json) result2 <- toJSON(result2)
    
    return(result2)
}

