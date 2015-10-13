#load RMySQL library for reading from the database
library(RMySQL)
library(qpcR)

numberOfWells<-16
scalingFactor<-900000

fluorescence_data <- function(dbname,dbuser,dbpassword,experimentID,stageID,calibrationID){
	#load chaipcr database
	message("db: ", dbname)
	message("experiment id: ", experimentID)
	message("stage id: ", stageID)
	message("calibration id: ", calibrationID)
	
	dbconn <- dbConnect(RMySQL::MySQL(), user=dbuser, pwd=dbpassword, dbname=dbname)
	
	#extract data from database
   	queryData<-sprintf("SELECT well_num, cycle_num, AVG(fluorescence_value) as fluorescence FROM fluorescence_data LEFT OUTER JOIN ramps on ramps.id = fluorescence_data.ramp_id INNER JOIN steps ON steps.id = fluorescence_data.step_id OR steps.id = ramps.next_step_id WHERE steps.stage_id=%d AND fluorescence_data.experiment_id=%d GROUP BY well_num, cycle_num ORDER BY well_num, cycle_num", stageID, experimentID)
	fluorescenceData <- dbGetQuery(dbconn, queryData) 
	
    queryWaterCalibration<-sprintf("SELECT well_num, fluorescence_value as fluorescence_wc FROM fluorescence_data WHERE experiment_id=%d AND step_id=2 ORDER BY well_num", calibrationID)
	waterCalibrationData <- dbGetQuery(dbconn, queryWaterCalibration)  

	queryFluorescenceCalibration<-sprintf("SELECT well_num, fluorescence_value as fluorescence_c FROM fluorescence_data WHERE experiment_id=%d AND step_id=4 ORDER BY well_num",calibrationID)
    fluorescenceCalibrationData <- dbGetQuery(dbconn, queryFluorescenceCalibration)

	dbDisconnect(dbconn)
	
	#perform calibration
	mergeData <- merge(fluorescenceData, waterCalibrationData)
	mergeData <- merge(mergeData, fluorescenceCalibrationData)
        mergeData$F = scalingFactor*(mergeData$fluorescence-mergeData$fluorescence_wc)/(mergeData$fluorescence_c-mergeData$fluorescence_wc)
    #print(data.frame(mergeData$well_num,mergeData$cycle_num,mergeData$F))
	
	return (data.frame(mergeData$well_num,mergeData$cycle_num,mergeData$F))
}

baseline_subtracted_ct_data <- function(dbname,dbuser,dbpassword,experimentID,stageID,calibrationID){

        #load chaipcr database
        message("db: ", dbname)
		message("experiment id: ", experimentID)
        message("stage id: ", stageID)
        message("calibration id: ", calibrationID)

        dbconn <- dbConnect(RMySQL::MySQL(), user=dbuser, pwd=dbpassword, dbname=dbname)

        #extract data from database
        queryData<-sprintf("SELECT well_num, cycle_num, AVG(fluorescence_value) as fluorescence FROM fluorescence_data LEFT OUTER JOIN ramps on ramps.id = fluorescence_data.ramp_id INNER JOIN steps ON steps.id = fluorescence_data.step_id OR steps.id = ramps.next_step_id WHERE steps.stage_id=%d AND fluorescence_data.experiment_id=%d GROUP BY well_num, cycle_num ORDER BY well_num, cycle_num", stageID,experimentID)
        fluorescenceData <- dbGetQuery(dbconn, queryData)

        queryWaterCalibration<-sprintf("SELECT well_num, fluorescence_value as fluorescence_wc FROM fluorescence_data WHERE experiment_id=%d AND step_id=2 ORDER BY well_num", calibrationID)
        waterCalibrationData <- dbGetQuery(dbconn, queryWaterCalibration)

        queryFluorescenceCalibration<-sprintf("SELECT well_num, fluorescence_value as fluorescence_c FROM fluorescence_data WHERE experiment_id=%d AND step_id=4 ORDER BY well_num",calibrationID)
        fluorescenceCalibrationData <- dbGetQuery(dbconn, queryFluorescenceCalibration)

        dbDisconnect(dbconn)

        #perform calibration
        mergeData <- merge(fluorescenceData, waterCalibrationData)
        mergeData <- merge(mergeData, fluorescenceCalibrationData)
        mergeData$F <- scalingFactor*(mergeData$fluorescence)/(mergeData$fluorescence_c-mergeData$fluorescence_wc)

        data <- data.frame(mergeData$well_num,mergeData$cycle_num,mergeData$F)

        #format data for qPCR functions
        Cycles <- unique(data$mergeData.cycle_num)
        wellNumber <- unique(data$mergeData.well_num)
        formattedData<-data.frame(Cycles)
        for(i in seq_along(wellNumber))
            formattedData[[paste("Well_num", toString(wellNumber[i]), " ")]]<-subset(data, mergeData.well_num==wellNumber[i])$mergeData.F

        #curve fit the data  with model 14 in qPCR library, baseline subtraction is the average of fluorescence from cycles 1 to 5
        fitData <- modlist(formattedData, baseline="mean", basecyc=1:5)

        #find ct values on an individual well basis, different thersholds for each well
        ct_Values <- getPar(fitData, "curve")["ct",]

        #remove ct values that are the max cycles
        ct_Values[ct_Values==max(Cycles)] <- NA

        fitDataPoints<-data.frame(Cycles)
        for(i in seq_along(wellNumber))
            fitDataPoints[[paste("Well_num", toString(wellNumber[i]), " ")]] <- predict(fitData[[i]])
	    
        return(list(fitDataPoints , ct_Values))
}
