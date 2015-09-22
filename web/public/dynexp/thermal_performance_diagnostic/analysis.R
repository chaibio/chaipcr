#load RMySQL library for reading from the database
library(RMySQL)
library(jsonlite)

numberOfWells<-16

analysis <- function(dbname,dbuser,dbpassword,experimentID){
	#load chaipcr database
	message("db: ", dbname)
	message("dbuser: ", dbuser)
	message("dbpassword: ", dbpassword)
	message("experiment id: ", experimentID)

	dbconn <- dbConnect(RMySQL::MySQL(), user=dbuser, pwd=dbpassword, dbname=dbname)

   	queryData<-sprintf("SELECT well_num, cycle_num, AVG(fluorescence_value) as fluorescence FROM fluorescence_data WHERE experiment_id=%d GROUP BY well_num, cycle_num ORDER BY well_num, cycle_num", experimentID)
	fluorescenceData <- fetch(dbSendQuery(dbconn, queryData),n=-1)   
	
	dbDisconnect(dbconn)
	
#	return (toJSON(fluorescenceData))
    return (toJSON(list(result=c("A", "B"))))
}