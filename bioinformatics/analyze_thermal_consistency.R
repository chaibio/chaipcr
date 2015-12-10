# chaipcr/web/public/dynexp/thermal_consistency/analyze.R
# 72C thermal consistency test

library(jsonlite)

analyze_thermal_consistency <- function(#floor_temp, # hard-coded inside of the function
    db_usr, db_pwd, db_host, db_port, db_name, 
    exp_id, 
    #stage_id, # hard-coded inside of the function
    calib_id, 
    min_fdiff_real=1e2, top_N=4, min_frac_report=0.1, 
    verbose=FALSE, 
    out_json=TRUE, 
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
                        min_fdiff_real, top_N, min_frac_report, 
                        verbose, 
                        show_running_time)
    
    names(mc_w72c) <- c('mc_out', '72c_fluorescence')
    
    if (out_json) mc_w72c <- toJSON(mc_w72c)
    
    return(mc_w72c)
    #return(toJSON(mc_w72c))
}

