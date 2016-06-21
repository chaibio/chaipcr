# melt curve data and fluorescence within 1C range

melt_1cr <- function(floor_temp, 
                     db_usr, db_pwd, db_host, db_port, db_name, 
                     exp_id, stage_id, calib_info, 
                     dye_in='FAM', dyes_2bfild=NULL, 
                     dcv=TRUE, # logical, whether to perform multi-channel deconvolution
                     max_temp=1000.1, 
                     mc_plot=FALSE, 
                     show_running_time=FALSE,
                     ... # options to pass onto `mc_tm_pw`
                     ) {
    
    # start counting for running time
    func_name <- 'melt_1cr'
    start_time <- proc.time()[['elapsed']]
    
    mc_out <- process_mc(db_usr, db_pwd, db_host, db_port, db_name, # for connecting to MySQL database
                         exp_id, stage_id, calib_info, # for selecting data to analyze
                         dye_in, dyes_2bfild, 
                         dcv, max_temp, mc_plot, extra_output=TRUE, show_running_time, ...)
    
    mc_tm <- lapply(mc_out[['mc_bywell']], 
                    function(channel_ele) lapply(channel_ele, 
                                                 function(well_ele) well_ele[['tm']]))
    
    # For each well, average the calibrated fluorescence values for the temperatures 72-73C
    mc_cols <- colnames(mc_out[['fc_wT']][[1]])
    temp_cols <- mc_cols[grepl('temp', mc_cols)]
    fluo_cols <- mc_cols[grepl('fluo', mc_cols)]
    if (length(temp_cols) != length(fluo_cols)) {
        stop('Number of temperature columns is not equal to number of fluorescence columns.') }
    
    fluo_1cr <- lapply(mc_out[['fc_wT']], function(channel_ele) {
        tempsl_1cr_pch <- alply(channel_ele[,temp_cols], .margins=2, 
            .fun=function(temps_pw) {
                tempsl <- temps_pw >= floor_temp & temps_pw < floor_temp + 1
                tempsl[is.na(tempsl)] <- FALSE
                return(tempsl)
                })
        fluo_1cr_pch <- sapply(1:length(fluo_cols), 
                           function(i) mean(channel_ele[tempsl_1cr_pch[[i]], fluo_cols[i]]))
        names(fluo_1cr_pch) <- fluo_cols
        return(fluo_1cr_pch)
        })
    
    mc_w1cr <- list('mc_tm'=mc_tm, '1cr_fluorescence'=fluo_1cr, 'num_channels'=mc_out[['num_channels']]) # each element is a list whose each element represents a channel
    
    # report time cost for this function
    end_time <- proc.time()[['elapsed']]
    if (show_running_time) message('`', func_name, '` took ', round(end_time - start_time, 2), ' seconds.')
    
    return(mc_w1cr)
}
