# chaipcr/web/public/dynexp/thermal_consistency/analyze.R
# 72C thermal consistency test

library(jsonlite)

analyze_thermal_consistency <- function(#floor_temp, # hard-coded inside of the function
    db_usr, db_pwd, db_host, db_port, db_name, 
    exp_id, 
    #stage_id, # hard-coded inside of the function
    calib_id, 
    dcv=TRUE, 
    mc_plot=FALSE, 
    verbose=FALSE, 
    out_json=TRUE, 
    show_running_time=FALSE, 
    ... # options to pass onto `mc_tm_pw`
    )
{
    # hard-coded arguments
    floor_temp <- 72
    stage_id <- 4
    # passed onto `mc_tm_pw`, different than default
    qt_prob <- 0.1
    max_normd_qtv <- 0.9
    
    mc_w72c <- melt_1cr(floor_temp, 
                        db_usr, db_pwd, db_host, db_port, db_name, 
                        exp_id, stage_id, calib_id, channel, 
                        dcv, 
                        mc_plot, 
                        verbose, 
                        show_running_time, 
                        qt_prob=qt_prob, max_normd_qtv=max_normd_qtv, # passed onto `mc_tm_pw`, different than default
                        ...)
    
    names(mc_w72c) <- c('mc_tm', '72c_fluorescence')
    
    if (out_json) mc_w72c <- toJSON(mc_w72c)
    
    return(mc_w72c)
    #return(toJSON(mc_w72c))
}

