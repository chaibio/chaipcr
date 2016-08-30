# chaipcr/web/public/dynexp/thermal_consistency/analyze.R
# 72C thermal consistency test

library(jsonlite)

# constants
MIN_FLUORESCENCE_VAL <- 800000
MIN_TM_VAL <- 77
MAX_TM_VAL <- 81
MAX_DELTA_TM_VAL <- 2


analyze_thermal_consistency <- function(#floor_temp, # hard-coded inside of the function
    db_usr, db_pwd, db_host, db_port, db_name, 
    exp_id, 
    #stage_id, # hard-coded inside of the function
    calib_info, 
    dcv=FALSE, 
    out_json=TRUE, 
    ... # options to pass onto `mc_tm_pw`
    )
{
    # hard-coded arguments
    stage_id <- 4
    # passed onto `mc_tm_pw`, different than default
    qt_prob <- 0.1
    max_normd_qtv <- 0.9
    channel <- '1'
    
    
    # process the data from only one channel
    
    mc_72c <- process_mc(
        db_usr, db_pwd, db_host, db_port, db_name, 
        exp_id, stage_id, calib_info, 
        dcv=dcv, extra_output=TRUE, 
        qt_prob=qt_prob, max_normd_qtv=max_normd_qtv, # passed onto `mc_tm_pw`, different than default
        ...)
    
    mc_tm <- lapply(mc_72c[['mc_bywell']][[as.character(channel)]], function(well_ele) well_ele[['tm']])
    
    tm_check <- list()
    min_Tm <- 100
    max_Tm <- 0
    
    for (well_name in names(mc_tm)) {
        top1_Tm_Area <- as.list(mc_tm[[well_name]][1,])
        top1_Tm <- top1_Tm_Area[['Tm']]
        if (is.na(top1_Tm)) {
            Tm_bool <- FALSE
        } else {
            if (top1_Tm < min_Tm) min_Tm <- top1_Tm
            if (top1_Tm > max_Tm) max_Tm <- top1_Tm
            Tm_bool <- top1_Tm >= MIN_TM_VAL && top1_Tm <= MAX_TM_VAL }
        top1_Tm_Area[['Tm']] <- list(unbox(top1_Tm), unbox(Tm_bool))
        top1_Tm_Area[['Area']] <- unbox(top1_Tm_Area[['Area']])
        tm_check[[well_name]] <- top1_Tm_Area
        }
    
    delta_Tm <- max_Tm - min_Tm
    
    mc_72c_out<- list(
        'tm_check'=tm_check,
        'delta_Tm'=list(unbox(delta_Tm), unbox(delta_Tm <= MAX_DELTA_TM_VAL))
    )
    
    if (out_json) mc_72c_out <- toJSON(mc_72c_out)
    
    return(mc_72c_out)
    
}

