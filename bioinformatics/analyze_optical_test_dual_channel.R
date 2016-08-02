# chaipcr/web/public/dynexp/optical_test_dual_channel/analyze.R


library(jsonlite)


# constants

num_channels <- 2 # channel indice are numeric

calib_labels_FAM_HEX <- c('channel_1', 'channel_2')

# bounds of signal-to-noise ratio (SNR)
SNR_FAM_CH1_MIN <- 0.75
SNR_FAM_CH2_MAX <- 1
SNR_HEX_CH1_MAX <- 0.70
SNR_HEX_CH2_MIN <- 0.85

# fluo values: channel 1, channel 2
WATER_MAX <- c(80000, 7500)
WATER_MIN <- c(100, 50)


# signal-to-noise ratio discriminants for each well
dscrmnt_snr_fam <- function(snr_2chs) c(snr_2chs[1] > SNR_FAM_CH1_MIN, snr_2chs[2] < SNR_FAM_CH2_MAX)
dscrmnt_snr_hex <- function(snr_2chs) c(snr_2chs[1] < SNR_HEX_CH1_MAX, snr_2chs[2] > SNR_HEX_CH2_MIN)
dscrmnts_snr <- list(dscrmnt_snr_fam, dscrmnt_snr_hex)
names(dscrmnts_snr) <- calib_labels_FAM_HEX


# analyze function
analyze_optical_test_dual_channel <- function(
    db_usr, db_pwd, db_host, db_port, db_name, 
    exp_id, calib_info
    ) {
    
    
    db_etc_out <- db_etc(
        db_usr, db_pwd, db_host, db_port, db_name, 
        exp_id, stage_id=NULL, calib_info
    )
    db_conn <- db_etc_out[['db_conn']]
    
    fluo_qry <- sprintf(
        'SELECT step_id, well_num, fluorescence_value, channel
            FROM fluorescence_data
            WHERE experiment_id=%i AND cycle_num=1
            ORDER BY well_num, channel
        ', 
        exp_id
    )
    fluo_data <- dbGetQuery(db_conn, fluo_qry)
    
    num_wells <- length(unique(fluo_data[,'well_num']))
    
    calib_labels <- c('baseline', calib_labels_FAM_HEX, 'water')
    
    fluo_list <- lapply(
        calib_labels,
        function(calib_label) do.call(rbind, lapply(
                1:num_channels, 
                function(channel) fluo_data[
                      fluo_data[,'step_id'] == calib_info[[calib_label]][['step_id']]
                    & fluo_data[,'channel'] == channel,
                    'fluorescence_value']
        ))
    )
    
    names(fluo_list) <- calib_labels
    
    
    bool_list <- list()
    bool_mtx_dim <- c(num_channels, num_wells)
    
    bool_list[['baseline']] <- array(TRUE, dim=bool_mtx_dim)
    
    # water test
    bool_list[['water']] <- do.call(rbind, lapply(
        1:num_channels, 
        function(channel) {
            fluos_wc <- fluo_list[['water']][channel,]
            fluos_wc < WATER_MAX[channel] & fluos_wc > WATER_MIN[channel]
        }
    ))
    
    # FAM and HEX SNR test
    for (calib_label in calib_labels_FAM_HEX) {
        bool_list[[calib_label]] <- do.call(cbind, lapply(
            1:num_wells, 
            function(well_i) {
                signal_fluo_2chs <- fluo_list[[calib_label]][,well_i]
                water_fluo_2chs <- fluo_list[['water']][,well_i]
                snr_2chs <- (signal_fluo_2chs - water_fluo_2chs) / signal_fluo_2chs # element-wise operations
                dscrmnts_snr[[calib_label]](snr_2chs)
            } 
        ))
    }
    
    
    names(calib_labels) <- c('baseline', 'FAM', 'HEX', 'water')
    results <- lapply(
        1:num_wells, 
        function(well_i) lapply(
            calib_labels, 
            function(calib_label) lapply(
                1:num_channels, 
                function(channel) list(
                    unbox(fluo_list[[calib_label]][channel, well_i]),
                    unbox(bool_list[[calib_label]][channel, well_i])
                ) 
            )
        )
    )
    
    # FAM and HEX self-calibrated ratio test
    swd_list <- lapply(fluo_list[calib_labels_FAM_HEX],
        function(fluos_dye) do.call(rbind, lapply(1:num_channels,
            function(channel) fluos_dye[channel,] - fluo_list[['water']][channel,]
        ))
    )
    swd_normd <- lapply(1:num_channels, function(channel) {
        swd_target <- swd_list[[channel]][channel,]
        swd_target / mean(swd_target)
    })
    self_calib_list <- lapply(swd_list, 
        function(swd_dye) do.call(rbind, lapply(1:num_channels,
            function(channel) swd_dye[channel,] / swd_normd[[channel]]
        ))
    )
    ch12_ratios <- do.call(rbind, lapply(self_calib_list[calib_labels_FAM_HEX],
        function(self_calib_dye) self_calib_dye[1,] / self_calib_dye[2,]
    ))
    rownames(ch12_ratios) <- c('FAM', 'HEX') # just for view, not necessary for JSON output
    
    
    return(toJSON(list('optical_data'=results, 'Ch1:Ch2'=ch12_ratios)))
    
    }




