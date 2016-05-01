# chaipcr/web/public/dynexp/thermal_consistency/analyze.R
# 72C thermal consistency test

library(jsonlite)

analyze_thermal_consistency <- function(#floor_temp, # hard-coded inside of the function
    db_usr, db_pwd, db_host, db_port, db_name, 
    exp_id, 
    #stage_id, # hard-coded inside of the function
    calib_id, 
    dye_in='FAM', dyes_2bfild=NULL, 
    dcv=FALSE, 
    mc_plot=FALSE, 
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
    channel <- '1'
    
    mc_w72c <- melt_1cr(floor_temp, 
                        db_usr, db_pwd, db_host, db_port, db_name, 
                        exp_id, stage_id, calib_id, channel, 
                        dye_in, dyes_2bfild, 
                        dcv, 
                        mc_plot, 
                        show_running_time, 
                        qt_prob=qt_prob, max_normd_qtv=max_normd_qtv, # passed onto `mc_tm_pw`, different than default
                        ...)
    
    names(mc_w72c) <- c('mc_tm', '72c_fluorescence')
    
    mc_w72c_simplified <- lapply(mc_w72c, function(ele) ele[[as.character(channel)]])
    
    top1_Tms <- sapply(mc_w72c_simplified[['mc_tm']], function(ele) ele[1, 'Tm'])
    min_Tm <- min(top1_Tms)
    max_Tm <- max(top1_Tms)
    delta_Tm <- max_Tm - min_Tm
    min_72c_fluo <- min(mc_w72c_simplified[['72c_fluorescence']])
    
    valid_boxed <- list(
        'MIN_TM' = list(min_Tm, min_Tm >= 77), 
        'MAX_TM' = list(max_Tm, max_Tm <= 81), 
        'MAX_DELTA_TM' = list(delta_Tm, delta_Tm <= 2),
        'MIN_FLUORESCENCE' = list(min_72c_fluo, min_72c_fluo >= 8000000))
    valid_unboxed <- lapply(valid_boxed, function(ele1) lapply(ele1, function(ele2) unbox(ele2)))
    
    mc_w72c_simplified[['valid']] <- valid_unboxed
    
    if (out_json) mc_w72c_simplified <- toJSON(mc_w72c_simplified)
    
    return(mc_w72c_simplified)
    #return(toJSON(mc_w72c_simplified))
}

