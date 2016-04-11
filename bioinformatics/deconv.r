# color compensation / multi-channel deconvolution


# function: get cross-over constant matrix k
get_k <- function(
                  db_conn, # MySQL database connection
                  dcv_exp_ids, # deconvolution experiment ids, i.e. the data in these experiments are for constructing deconvolution matrix. a named vector (by channel) where each element is the experiment id using the target dye of each channel
                  dcv_target_step_ids, # a named vector (by channel) where each element is the step id using the target dye of each channel
                  calib_id, # calibration experiment id associated with the deconvolution experiment
                  well_proc='dim3' # options: 'mean', 'dim3'.
                  ) { 
    
    channels <- names(dcv_target_step_ids)
    names(channels) <- channels
    
    k_list_bydy <- lapply(channels, function(channel) { 
        k_qry <- sprintf('SELECT fluorescence_value, well_num, channel 
                              FROM fluorescence_data 
                              WHERE experiment_id=%d AND step_id=%d AND cycle_num=1 
                              ORDER BY well_num, channel', 
                              dcv_exp_ids[as.character(channel)], 
                              dcv_target_step_ids[as.character(channel)])
        k_data_1dye <- dbGetQuery(db_conn, k_qry)
        k_data_1dye_bych <- lapply(channels, function(channel) k_data_1dye[k_data_1dye[,'channel'] == channel,])
        k_mtx_1dye <- do.call(rbind, 
                              lapply(channels, 
                                  function(channel) {
                                      k_data_1dye_1ch <- k_data_1dye_bych[[channel]][,'fluorescence_value']
                                      kd11_mtx <- matrix(k_data_1dye_1ch, 
                                                         nrow=1, ncol=length(k_data_1dye_1ch))
                                      kd11_calibd <- optic_calib(kd11_mtx, db_conn, calib_id, channel)[['fluo_calib']]
                                      fluo_kc <- kd11_calibd[,2:ncol(kd11_calibd)]
                                      names(fluo_kc) <- unique(k_data_1dye[,'well_num'])
                                      return(fluo_kc)
                                      })) # rows are channels, columns are wells
        })
    
    dye_names <- paste('dye', channels, sep='_')
    well_names <- colnames(k_list_bydy[[1]])
    
    k_inv_array <- array(NA, 
                         dim=c(length(dye_names), length(channels), length(well_names)),
                         dimnames=list(dye_names, channels, well_names))
    
    if (well_proc == 'mean') {
        k <- do.call(cbind, 
                     lapply(k_list_bydy, 
                            function(k_mtx_1dye) {
                                k_mean_vec_1dye <- sapply(channels, function(channel) mean(as.numeric(k_mtx_1dye[channel,]))) # a named vector whose each channel element is the mean of optical-calibrated fluo values across all the wells
                                k_1dye <- k_mean_vec_1dye / sum(k_mean_vec_1dye) }))
        # rownames(k_out) <- channels # not necessary. rownames are inherited as channels
        colnames(k) <- dye_names
        # inverse of k
        k_inv_mtx <- solve(k)
        for (well_name in well_names) k_inv_array[,,well_name] <- k_inv_mtx
    
    } else if (well_proc == 'dim3') {
        num_channels <- length(channels)
        k <- array(NA, 
                   dim=c(num_channels, num_channels, length(well_names)), 
                   dimnames=list(channels, dye_names, well_names))
        for (i in 1:num_channels) {
            for (well_name in well_names) {
                k_vec <- k_list_bydy[[i]][,well_name]
                k[,i,well_name] <- k_vec / sum(k_vec) }}
        # inverse of k
        for (well_name in well_names) k_inv_array[,,well_name] <- solve(k[,,well_name])
        }
    
    return(list('k'=k, 'k_inv_array'=k_inv_array))
    }


# multi-channel deconvolution
deconv <- function(array2dcv, # dim1 must be channel, dim3 must be well; dim2 is cycle for amplification and temperature point for melting curve
                   k_inv_array ) {
    
    array2dcv <<- array2dcv # test
    
    a2d_dim1 <- dim(array2dcv)[1]
    a2d_dim2 <- dim(array2dcv)[2]
    a2d_dim3 <- dim(array2dcv)[3]
    a2d_dimnames <- dimnames(array2dcv)
    
    # if data only has 1 cycle (amplification) or 1 temperature point (melt curve)
    if (is.na(a2d_dim3)) array2dcv <- array(c(array2dcv), 
                                            dim=c(a2d_dim1, 1, a2d_dim2), 
                                            dimnames=list(a2d_dimnames[[1]], '1', a2d_dimnames[[2]]))
    
    dcvd_by_dim2_well <- lapply(1:a2d_dim2, 
        function(dim2_i) do.call(cbind, lapply(1:a2d_dim3, 
            function(well_i) k_inv_array[,,well_i] %*% array2dcv[,dim2_i,well_i]))) # dim2 is cycle_num for amp and temperature for melt curve
    
    dcvd_array <- array(NA, dim(array2dcv))
    for (dim2_i in 1:dim(array2dcv)[2]) dcvd_array[,dim2_i,] <- dcvd_by_dim2_well[[dim2_i]]
    dimnames(dcvd_array) <- dimnames(array2dcv)
    
    # scale by channel to adjust for different fluorescence excitation strengths among dyes
    for (channel in dimnames(dcvd_array)[1]) {
        dcvd_array[channel,,] <- dcvd_array[channel,,] * scaling_factors_deconv[channel] }
    
    return(dcvd_array)
    }

