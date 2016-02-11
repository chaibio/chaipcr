# color compensation / multi-channel deconvolution


# function: get cross-over constant matrix k
get_k <- function(
                  db_conn, 
                  dcv_id, 
                  channels # need not be named, used as characters
                  ) { 
    
    water_qry <- sprintf('SELECT fluorescence_value, well_num, channel 
                              FROM fluorescence_data 
                              WHERE experiment_id=%d AND step_id=%d 
                              ORDER BY well_num, channel', 
                              dcv_id, oc_water_step_id)
    water_data <- dbGetQuery(db_conn, water_qry)
    
    k_data_list_bych <- lapply(channels, function(channel) {
        k_qry <- sprintf('SELECT fluorescence_value, well_num, channel 
                              FROM fluorescence_data 
                              WHERE experiment_id=%d AND step_id=%d 
                              ORDER BY well_num, channel', 
                              dcv_id, dcv_target_step_ids[[as.character(channel)]])
        k_data_1ch <- dbGetQuery(db_conn, k_qry)
        k_data_1ch[,'fluorescence_value'] <- k_data_1ch[,'fluorescence_value'] - water_data[,'fluorescence_value']
        return(k_data_1ch)
        })
    
    k_data_mtx <- cbind(k_data_list_bych[[1]][,'well_num'], k_data_list_bych[[1]][,'channel'], 
                        do.call(cbind, lapply(k_data_list_bych, function(ele) ele[,1])))
    colnames(k_data_mtx) <- c('well_num', 'channel', sapply(channels, function(channel) paste('dye', channel, sep='_')))
    
    well_nums <- unique(k_data_mtx[,'well_num'])
    
    k_data_list_bywell <- lapply(well_nums, 
                                 function(well_num) {
                                    well_mtx <- k_data_mtx[k_data_mtx[,'well_num'] == well_num, 2:ncol(k_data_mtx)]
                                    rownames(well_mtx) <- well_mtx[,'channel']
                                    return(well_mtx[,2:ncol(well_mtx)]) })
    
    k_list_bywell <- lapply(k_data_list_bywell, 
                            function(well_mtx) {
                                k_mtx <- do.call(cbind, 
                                                 alply(well_mtx, .margins=2, 
                                                       .fun=function(column) column / sum(column)))
                                colnames(k_mtx) <- colnames(well_mtx)
                                return(k_mtx) })
    names(k_list_bywell) <- well_nums
    
    return(k_list_bywell)
    }


# multi-channel deconvolution
deconv <- function(array2dcv, # dim1 must be channel, dim3 must be well
                   k_list_bywell ) {
    
    dcvd_by_dim2_well <- lapply(1:dim(array2dcv)[2], 
        function(dim2_i) do.call(cbind, lapply(1:dim(array2dcv)[3], 
            function(well_i) solve(k_list_bywell[[well_i]]) %*% array2dcv[,dim2_i,well_i]))) # dim2 is cycle_num for amp and temperature for melt curve
    
    dcvd_array <- array(NA, dim(array2dcv))
    for (dim2_i in 1:dim(array2dcv)[2]) dcvd_array[,dim2_i,] <- dcvd_by_dim2_well[[dim2_i]]
    dimnames(dcvd_array) <- dimnames(array2dcv)
    
    return(dcvd_array)
    }

