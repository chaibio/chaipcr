# amp_realtime

# load libraries
library(plyr)
library(qpcR)
library(reshape2)
library(RMySQL)


# function: set global constants using `<<-`
set_global <- function(num_wells=16, scaling_factor=9e5) {
    num_wells <<- num_wells
    scaling_factor <<- scaling_factor
    message('user-defined number of wells: ', num_wells)
    message('scaling factor for water calibration: ', scaling_factor)
    
    return(NULL)
    }


# function: load MySQL database and process data
load_data <- function(db_usr, db_pwd, db_host, db_port, db_name) {
    
    message('db: ', db_name)
    db_conn <- dbConnect(RMySQL::MySQL(), 
                         user=db_usr, 
                         password=db_pwd, 
                         host=db_host, 
                         port=db_port, 
                         dbname=db_name)
    
    # transform MySQL tables into R data frames. Later data will be retrieved from R data frames instead of MySQL database.
    tb_names <- c(as.matrix(dbGetQuery(db_conn, 'SHOW TABLES')))
    tables <- lapply(tb_names, function(tb_name) dbGetQuery(db_conn, sprintf('SELECT * from %s', tb_name)))
    names(tables) <- tb_names
    
    
    # build a table showing association of info columns; from column with fewer duplicated values to column with more
    
    add_info <- function(row1, hit_tb, hit_col, qry_col, info_cols) {
        info <- hit_tb[hit_tb[, hit_col] == row1[, qry_col], info_cols]
        if (length(info) == 0) info <- matrix(NA, nrow=1, ncol=length(info_cols)) # handle no hits
        cbind(row1, info) }
    
    steps_w_stages <- tables[['steps']][, c('id', 'stage_id')]
    colnames(steps_w_stages)[1] <- 'step_id'
    
    steps_stages <- adply(steps_w_stages, .margins=1, .fun=add_info, 
        hit_tb=tables[['stages']], hit_col='id', qry_col='stage_id', info_cols=c('protocol_id', 'stage_type'))
    
    steps_stages_protocols <- adply(steps_stages, .margins=1, .fun=add_info, 
        hit_tb=tables[['protocols']], hit_col='id', qry_col='protocol_id', info_cols='experiment_definition_id')
    colnames(steps_stages_protocols)[5] <- 'experiment_definition_id'
    
    tb_expdef <- tables[['experiment_definitions']]
    tb_exp <- tables[['experiments']]
    expdef_calibs <- adply(tb_expdef, .margins=1, .fun=add_info, 
                           hit_tb=unique(tb_exp[, c('experiment_definition_id', 'calibration_id')]), 
                           hit_col='experiment_definition_id', qry_col='id', info_cols='calibration_id')
    colnames(expdef_calibs)[5] <- 'calibration_id'
    exps_combined <- adply(tb_expdef, .margins=1, 
                           .fun=function(row1) paste(tb_exp[tb_exp['experiment_definition_id'] == row1[,'id'], 
                                                            'id'], collapse=','))
    expdef_calibs_exps <- cbind(expdef_calibs[, c('id', 'calibration_id')], exps_combined[, 'V1'])
    colnames(expdef_calibs_exps)[3] <- 'experiment_ids'
    
    # sspee: steps_stages_protocols_experiment_definitions_experiments
    sspee <- adply(steps_stages_protocols, .margins=1, .fun=add_info, 
        hit_tb=expdef_calibs_exps, hit_col='id', qry_col='experiment_definition_id', 
        info_cols=c('calibration_id', 'experiment_ids'))
    colnames(sspee)[6:7] <- c('calibration_id', 'experiment_ids')
    tables[['sspee']] <- sspee
    
    return(tables)
    }


# function: get data based on exp_id, and perform calibration 
get_data_calib <- function(exp_id, tables) {
    
    sspee <- tables[['sspee']]
    
    # find calib_id and stg_id based on exp_id
    cyc_rows <- sspee[(sspee[,'stage_type'] == 'cycling') & (sspee[,'experiment_ids'] == exp_id),]
    calib_id <- unique(cyc_rows[,'calibration_id'])
    if (length(calib_id) > 1) {
        stop('there are more than one values of calibration_id for cycling associated with the given exp_id') }
    stg_id <- unique(cyc_rows[,'stage_id'])
    if (length(stg_id) > 1) {
        stop('there are more than one values of stage_id for cycling associated with the given exp_id') }
    
    message('experiment_id: ', exp_id)
    message('calibration_id: ', calib_id)
    message('stage_id: ', stg_id)
    
    # get fluorescence data as fluo_sel based on exp_id
    fluo_dat <- tables[['fluorescence_data']]
    fluo_dat <- fluo_dat[with(fluo_dat, order(step_id, cycle_num, well_num)),]
    fluo_sel <- fluo_dat[unlist(alply(fluo_dat, .margins=1, 
        function(row1) { (row1[,'step_id'] %in% cyc_rows[,'step_id']) | (row1[,'ramp_id'] %in% cyc_rows[,'step_id'])})),]
    
    # get calibration data
    calib_dat <- fluo_dat[fluo_dat[,'experiment_id'] == calib_id,]
    calib_water <- calib_dat[calib_dat[,'step_id'] == 2,]
    calib_signal <- calib_dat[calib_dat[,'step_id'] == 4,]
    if (!(all(dim(calib_water) == dim(calib_signal)))) {
        stop('dimensions not equal between calib_water and calib_signal') }
    num_calibd_wells <- dim(calib_water)[1]
    if (!(num_calibd_wells == num_wells)) {
        stop('number of calibrated wells is not equal to user-defined number of wells') }
    
    # perform calibration
    rep_times <- dim(fluo_sel)[1] / num_wells # assume dim(calib_water) == dim(calib_signal) and num_calibd_wells == num_wells
    calib_water_fluo  <- rep(calib_water [,'fluorescence_value'], times=rep_times)
    calib_signal_fluo <- rep(calib_signal[,'fluorescence_value'], times=rep_times)
    fluo_sel[,'fluorescence_value'] <- scaling_factor * (fluo_sel[,'fluorescence_value'] - calib_water_fluo) / (calib_signal_fluo - calib_water_fluo)
    
    # cast fluo_sel into a pivot table organized by cycle_num (row label) and well_num (column label), average the data from all the available steps/ramps for each well and cycle
    fluo_melt <- melt(fluo_sel, id.vars=c('step_id', 'well_num', 'cycle_num', 'experiment_id', 'ramp_id'), 
                      measure.vars='fluorescence_value')
    fluo_cast <- dcast(fluo_melt, cycle_num ~ well_num, mean)
    
    return(fluo_cast)
    }


# function: baseline subtraction and Ct
baseline_ct <- function(fluo_cast, 
                        model, baseline, basecyc, # modlist parameters
                        type, cp, # getPar parameters
                        ...) {
    fitted_curves <- modlist(fluo_cast, model=model, baseline=baseline, basecyc=basecyc)
    ct_eff <- getPar(fitted_curves, type=type, cp=cp)
    return(ct_eff)
    }




# workflow


# user inputs

# set_global
num_wells <- 16
scaling_factor <- 9e5

# load_data
db_usr <- 'usr0'
db_pwd <- '0rsu'
db_host <- 'localhost'
db_port <- 3306
db_name <- 'josh1' # used: 'jyothi_data', 'josh'

# get_data_calib
exp_id <- 10 # used: 10, 23

# baseline_ct
model <- l4
baseline <- 'lin'
basecyc <- 1:5
type <- 'curve'
cp <- 'cpD2'


# standard operations
set_global(num_wells, scaling_factor)
tables <- load_data(db_usr, db_pwd, db_host, db_port, db_name)
fluo_cast <- get_data_calib(exp_id, tables)
ct_eff <- baseline_ct(fluo_cast, model, baseline, basecyc, type, cp)


# test operations

exp_id_10 <- 10
fluo_cast_10 <- get_data_calib(exp_id_10, tables)
ct_eff_10 <- baseline_ct(fluo_cast_10, model, baseline, basecyc, type, cp)
plot(fluo_cast_10[,'6'])

exp_id_23 <- 23
fluo_cast_23 <- get_data_calib(exp_id_23, tables)
ct_eff_23 <- baseline_ct(fluo_cast_23, model, baseline, basecyc, type, cp)
plot(fluo_cast_23[,'11'])


#

