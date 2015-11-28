#load RMySQL library for reading from the database
library(jsonlite)

analyze <- function(db_usr, db_pwd, db_host, db_port, db_name, experiment_id, calibration_id){
	results = process_mc(db_usr,db_pwd,db_host,db_port,db_name,experiment_id,4,calibration_id)
	return (toJSON(results))
}
