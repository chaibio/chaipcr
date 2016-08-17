# chaipcr/web/public/dynexp/optical_test_single_channel/analyze.R

library(jsonlite)

# constants
MIN_EXCITATION_FLUORESCENCE <- 5120
MIN_EXCITATION_FLUORESCENCE_MULTIPLE <- 3
MAX_EXCITATION <- 384000
baseline_step_id <- 12
excitation_step_id <- 13


analyze_optical_test_single_channel <- function(
    db_usr, db_pwd, db_host, db_port, db_name, 
    exp_id, 
    calib_info, # not used for testing
    ... # to receive unused arguments
    ) {
    
    db_etc_out <- db_etc(
        db_usr, db_pwd, db_host, db_port, db_name, 
        exp_id, stage_id=NULL, calib_info=calib_info)
    db_conn <- db_etc_out[['db_conn']]
    
    step_ids <- c(baseline_step_id, excitation_step_id)
    
    ot_list <- lapply(
        step_ids,
        function(step_id) {
            ot_qry <- sprintf(
                'SELECT fluorescence_value
                    FROM fluorescence_data
                    WHERE experiment_id=%i AND step_id=%i AND cycle_num=1
                    ORDER BY well_num', 
                exp_id, step_id)
            as.numeric(dbGetQuery(db_conn, ot_qry)[,1])
            })
    
    names(ot_list) <- step_ids
    
    # assuming the 2 elements of `ot_list` are the same in length (number of wells)
    results <- lapply(
        1:length(ot_list[[1]]),
        function(well_i) {
            baseline <- ot_list[[as.character(baseline_step_id)]][well_i]
            excitation <- ot_list[[as.character(excitation_step_id)]][well_i]
            # valid <- (excitation >= MIN_EXCITATION_FLUORESCENCE) && (excitation / baseline >= MIN_EXCITATION_FLUORESCENCE_MULTIPLE) && (excitation <= MAX_EXCITATION) # old
            valid <- (excitation >= MIN_EXCITATION_FLUORESCENCE) && (baseline < MIN_EXCITATION_FLUORESCENCE) && (excitation <= MAX_EXCITATION) # Josh, 2016-08-15
            result <- list('baseline'=baseline, 'excitation'=excitation, 'valid'=valid)
            return(lapply(result, function(ele) unbox(ele)))
            })
    
    return(toJSON(list('optical_data'=results)))
    }




