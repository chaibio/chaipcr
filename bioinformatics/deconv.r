# color compensation / multi-channel deconvolution


# function: get cross-over constant matrix k
get_k <- function(
    db_conn, # MySQL database connection
    dcv_exp_info, # deconvolution experiment ids, i.e. the data in these experiments are for constructing deconvolution matrix. a named vector (by channel) where each element is the experiment id using the target dye of each channel
    well_proc='dim3' # options: 'mean', 'dim3'.
    ) { 
    
    dei_names <- names(dcv_exp_info)
    channel_names <- dei_names[2:length(dei_names)]
    channels <- sapply(channel_names, function(channel_name) strsplit(channel_name, '_')[[1]][2])
    num_channels <- length(channels)
    names(channel_names) <- channels
    
    dcv_list <- get_full_calib_data(db_conn, dcv_exp_info)
    
    water_data <- dcv_list[['water']]
    well_nums <- colnames(water_data)
    num_wells <- length(well_nums)
    
    k_list_bydy <- lapply(channel_names, function(channel_name) dcv_list[[channel_name]] - water_data)
    names(k_list_bydy) <- channels
    
    dye_names <- paste('dye_', channels)
    
    k_inv_array <- array(
        0, 
        dim=c(num_channels, num_channels, num_wells), 
        dimnames=list(channels, dye_names, well_nums)
    )
    
    k_singular <- ''
    
    if (well_proc == 'mean') {
        k <- as.matrix(do.call(cbind, lapply(channels, function(channel) {
            k_data_1dye <- rowMeans(k_list_bydy[[channel]])
            k_data_1dye / sum(k_data_1dye)
        })))
        colnames(k) <- dye_names
        k_inv <- tryCatch(solve(k; suppress_warnings=true, error=err_e)
        if ('error' %in% class(k_inv)) {
            k_singular <- c('Well mean K matrix is singular. ')
        } else {
            for (well_num in well_nums) {
                k_inv_array[,,well_num] <- k_inv
            }
        }
        
    } else if (well_proc == 'dim3') {
        k <- k_inv_array
        k_singular_vec <- c()
        for (well_num in well_nums) {
            k_mtx <- as.matrix(do.call(cbind, lapply(channels, function(channel) {
                k_data_1dye <- k_list_bydy[[channel]][,well_num]
                k_data_1dye / sum(k_data_1dye)
            })))
            k[,,well_num] <- k_mtx
            k_inv <- tryCatch(solve(k_mtx; suppress_warnings=true), error=err_e)
            if ('error' %in% class(k_inv)) {
                k_singular_vec <- c(k_singular_vec, well_num)
            } else {
                k_inv_array[,,well_num] <- k_inv
            }
        }
        if (length(k_singular_vec) > 0) {
            k_singular <- sprintf(
                'Well-specific K matrix is singular for the following well(s): %s. ',
                paste(k_singular_vec, collapse=', ')
            )
        }
    }
    
    return(list('k'=k, 'k_inv_array'=k_inv_array, 'k_singular'=k_singular))
    }


# multi-channel deconvolution
deconv <- function(
    array2dcv, # dim1 must be channel, dim3 must be well; dim2 is cycle for amplification and temperature point for melting curve
    db_conn,
    calib_info
    ) {
    
    a2d_dim1 <- dim(array2dcv)[1]
    a2d_dim2 <- dim(array2dcv)[2]
    a2d_dim3 <- dim(array2dcv)[3]
    a2d_dimnames <- dimnames(array2dcv)
    
    # if data only has 1 cycle (amplification) or 1 temperature point (melt curve)
    if (is.na(a2d_dim3)) array2dcv <- array(c(array2dcv), 
                                            dim=c(a2d_dim1, 1, a2d_dim2), 
                                            dimnames=list(a2d_dimnames[[1]], '1', a2d_dimnames[[2]]))
    
    if (class(calib_info) == "numeric" || 
        sum(duplicated(sapply(calib_info, function(calib_ele) calib_ele[['step_id']]))) > 0
    ) {
        k_list_temp <- k_list
    } else {
        k_list_temp <- get_k(db_conn, calib_info, 'dim3')
    }
    
    k_inv_array = k_list_temp[['k_inv_array']]
    
    dcvd_by_dim2_well <- lapply(1:a2d_dim2, 
        function(dim2_i) do.call(cbind, lapply(1:a2d_dim3, 
            function(well_i) k_inv_array[,,well_i] %*% array2dcv[,dim2_i,well_i]))) # dim2 is cycle_num for amp and temperature for melt curve
    
    dcvd_array <- array(NA, dim(array2dcv))
    for (dim2_i in 1:dim(array2dcv)[2]) dcvd_array[,dim2_i,] <- dcvd_by_dim2_well[[dim2_i]]
    dimnames(dcvd_array) <- dimnames(array2dcv)
    
    # scale by channel to adjust for different fluorescence excitation strengths among dyes
    for (channel in dimnames(dcvd_array)[1]) {
        dcvd_array[channel,,] <- dcvd_array[channel,,] * scaling_factors_deconv[channel] }
    
    return(list('dcvd_array'=dcvd_array, 'k_list_temp'=k_list_temp))
    }

