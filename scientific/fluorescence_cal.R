#load RMySQL library for reading from the database
library(RMySQL)

numberOfWells<-16

fluorescence_data <- function(dbname,stageID,calibrationID){
	#load chaipcr database
	message("db: ", dbname)
	message("stage id: ", stageID)
	message("calibration id: ", calibrationID)
	
	dbconn <- dbConnect(RMySQL::MySQL(),  user='root', dbname=dbname)
	
	#extract data from database
   	queryData<-sprintf("SELECT well_num, cycle_num, AVG(fluorescence_value) as fluorescence FROM fluorescence_data LEFT OUTER JOIN ramps on ramps.id = fluorescence_data.ramp_id INNER JOIN steps ON steps.id = fluorescence_data.step_id OR steps.id = ramps.next_step_id WHERE steps.stage_id=%d GROUP BY well_num, cycle_num ORDER BY well_num, cycle_num", stageID)
	fluorescenceData <- fetch(dbSendQuery(dbconn, queryData),n=-1)   
	
    queryWaterCalibration<-sprintf("SELECT well_num, fluorescence_value as fluorescence_wc FROM fluorescence_data WHERE experiment_id=%d AND step_id=2 ORDER BY well_num", calibrationID)
	waterCalibrationData <- fetch(dbSendQuery(dbconn, queryWaterCalibration),n=-1)   

	queryFluorescenceCalibration<-sprintf("SELECT well_num, fluorescence_value as fluorescence_c FROM fluorescence_data WHERE experiment_id=%d AND step_id=4 ORDER BY well_num",calibrationID)
    fluorescenceCalibrationData <- fetch(dbSendQuery(dbconn, queryFluorescenceCalibration),n=-1)

	dbDisconnect(dbconn)
	
	#perform calibration
	mergeData <- merge(fluorescenceData, waterCalibrationData)
	mergeData <- merge(mergeData, fluorescenceCalibrationData)
	mergeData$F = (mergeData$fluorescence-mergeData$fluorescence_wc)/mergeData$fluorescence_c
    #print(data.frame(mergeData$well_num,mergeData$cycle_num,mergeData$F))
	
	return (data.frame(mergeData$well_num,mergeData$cycle_num,mergeData$F))
}