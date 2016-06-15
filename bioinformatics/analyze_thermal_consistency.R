# chaipcr/web/public/dynexp/thermal_consistency/analyze.R
# 72C thermal consistency test

library(jsonlite)

# constants
MIN_FLUORESCENCE_VAL <- 8000000
MIN_TM_VAL <- 77
MAX_TM_VAL <- 81
MAX_DELTA_TM_VAL <- 2


analyze_thermal_consistency <- function(#floor_temp, # hard-coded inside of the function
    db_usr, db_pwd, db_host, db_port, db_name, 
    exp_id, 
    #stage_id, # hard-coded inside of the function
    calib_info, 
    dye_in='FAM', dyes_2bfild=NULL, 
    dcv=FALSE, 
    max_temp=1000.1, 
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
    
    
    # process the data from only one channel
    
    mc_w72c <- melt_1cr(floor_temp, 
                        db_usr, db_pwd, db_host, db_port, db_name, 
                        exp_id, stage_id, calib_info, 
                        dye_in, dyes_2bfild, 
                        dcv, 
                        max_temp, 
                        mc_plot, 
                        show_running_time, 
                        qt_prob=qt_prob, max_normd_qtv=max_normd_qtv, # passed onto `mc_tm_pw`, different than default
                        ...)
    
    # names(mc_w72c) <- c('mc_tm', '72c_fluorescence')
    
    mc_w72c_simplified <- lapply(mc_w72c, function(ele) ele[[as.character(channel)]])
    
    mc_w72c_out <- list('tm_check'=list(), '72c_fluorescence'=list())
    min_Tm <- 100
    max_Tm <- 0
    
    for (well_name in names(mc_w72c_simplified[['mc_tm']])) {
        
        top1_Tm_Area <- as.list(mc_w72c_simplified[['mc_tm']][[well_name]][1,])
        top1_Tm <- top1_Tm_Area[['Tm']]
        if (is.na(top1_Tm)) {
            Tm_bool <- FALSE
        } else {
            if (top1_Tm < min_Tm) min_Tm <- top1_Tm
            if (top1_Tm > max_Tm) max_Tm <- top1_Tm
            Tm_bool <- top1_Tm >= MIN_TM_VAL && top1_Tm <= MAX_TM_VAL }
        top1_Tm_Area[['Tm']] <- list(unbox(top1_Tm), unbox(Tm_bool))
        top1_Tm_Area[['Area']] <- unbox(top1_Tm_Area[['Area']])
        mc_w72c_out[['tm_check']][[well_name]] <- top1_Tm_Area
        
        fluo_72c <- mc_w72c_simplified[['1cr_fluorescence']][well_name]
        mc_w72c_out[['72c_fluorescence']][[well_name]] <- list(unbox(fluo_72c), unbox(fluo_72c >= MIN_FLUORESCENCE_VAL))
        }
    
    delta_Tm <- max_Tm - min_Tm
    mc_w72c_out[['delta_Tm']] <- list(unbox(delta_Tm), unbox(delta_Tm <= MAX_DELTA_TM_VAL))
    
    # check whether the experiment is single-channel, if not, don't output '72c_fluorescence'
    db_conn <- dbConnect(RMySQL::MySQL(), 
                         user=db_usr, 
                         password=db_pwd, 
                         host=db_host, 
                         port=db_port, 
                         dbname=db_name)
    mcd_qry <- sprintf('SELECT channel
                       FROM melt_curve_data 
                       WHERE experiment_id=%d AND stage_id=%d',
                       exp_id, stage_id)
    mcd_channel <- dbGetQuery(db_conn, mcd_qry)
    channels <- unique(mcd_channel[,'channel'])
    if (length(channels) > 1) mc_w72c_out <- mc_w72c_out[c(1,3)]
    
    if (out_json) mc_w72c_out <- toJSON(mc_w72c_out)
    
    return(mc_w72c_out)
    
    
    # num_wells <- length(top1_Tms)
    
    # for (i in 1:num_wells) {
        # mc_w72c_simplified[[i]][['']]
        # }
    
    # min_72c_fluo <- min(mc_w72c_simplified[['72c_fluorescence']])
    
    # valid_boxed <- list(
        # 'MIN_TM' = list(min_Tm, min_Tm >= 77), 
        # 'MAX_TM' = list(max_Tm, max_Tm <= 81), 
        # 'MAX_DELTA_TM' = list(delta_Tm, delta_Tm <= 2),
        # 'MIN_FLUORESCENCE' = list(min_72c_fluo, min_72c_fluo >= 8000000))
    # valid_unboxed <- lapply(valid_boxed, function(ele1) lapply(ele1, function(ele2) unbox(ele2)))
    
    # mc_w72c_simplified[['valid']] <- valid_unboxed
    
    # if (out_json) mc_w72c_simplified <- toJSON(mc_w72c_simplified)
    
    # return(mc_w72c_simplified)
    # #return(toJSON(mc_w72c_simplified))
}

