# chaipcr/web/public/dynexp/hrm_calibration/analyze.R
# 72C thermal consistency test

library(jsonlite)

analyze <- function(#floor_temp, # hard-coded inside of the function
    db_usr, db_pwd, db_host, db_port, db_name, 
    exp_id, 
    #stage_id, # hard-coded inside of the function
    calib_id, 
    show_running_time=FALSE)
{
    # hard-coded arguments
    floor_temp <- 72
    stage_id <- 4
    
    mc_w72c <- melt_1cr(floor_temp, 
                        db_usr, db_pwd, db_host, db_port, db_name, 
                        exp_id, 
                        stage_id, 
                        calib_id, 
                        show_running_time)
    
    names(mc_w72c) <- c('mc_out', '72c_fluorescence')
    
    #return(mc_w72c)
    return(toJSON(mc_w72c))
}

