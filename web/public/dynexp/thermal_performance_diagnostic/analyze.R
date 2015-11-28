#load RMySQL library for reading from the database
library(RMySQL)
library(jsonlite)

#constants
deltaTSetPoint <- 1
highTemperature <- 95
lowTemperature <- 50

analyze <- function(db_usr, db_pwd, db_host, db_port, db_name, experiment_id, calibration_id){
	#load chaipcr database
	message("db: ", db_name)
	message("dbuser: ", db_usr)
	message("dbpassword: ", db_pwd)
	message("experiment id: ", experiment_id)

	#load chaipcr database
	dbconn <- dbConnect(RMySQL::MySQL(), user=db_usr, pwd=db_pwd, host=db_host, port=db_port, dbname=db_name)

	#extract data from database
	temperatureData <- list()
	queryTemperatureData<-sprintf("SELECT * FROM temperature_logs WHERE experiment_id=%d order by elapsed_time",experiment_id)
	temperatureData <- dbGetQuery(dbconn, queryTemperatureData)

	dbDisconnect(dbconn)

	#add a new row that is the average of the two heat block zones
	temperatureData$heat_block_zone_average_temp <- rowMeans(subset(temperatureData, select = c(heat_block_zone_1_temp, heat_block_zone_2_temp)))
	
	#calculate average ramp rates up and down of the heat block
	#first calculate the time the heat block reaches the high temperature/also the time the ramp up ends and the ramp down starts
	apprxRampUpEndTime <- min(temperatureData[temperatureData$heat_block_zone_average_temp>(highTemperature-deltaTSetPoint),'elapsed_time'])
	apprxRampDownStartTime <- max(temperatureData[temperatureData$heat_block_zone_average_temp>(highTemperature-deltaTSetPoint),'elapsed_time'])
	#calculate the time the ramp up starts and the ramp down ends
	apprxRampUpStartTime <- max(temperatureData[(temperatureData$heat_block_zone_average_temp<(lowTemperature+deltaTSetPoint)) & (temperatureData$elapsed_time<apprxRampUpEndTime),'elapsed_time'])
	apprxRampDownEndTime <- min(temperatureData[(temperatureData$heat_block_zone_average_temp<(lowTemperature+deltaTSetPoint)) & (temperatureData$elapsed_time>apprxRampDownStartTime),'elapsed_time'])
	#calculate the average ramp rate up and down in degrees C per second
	avgHeatBlockRampUpRate <- ((highTemperature-lowTemperature-2*deltaTSetPoint)*1000)/(apprxRampUpEndTime-apprxRampUpStartTime)
	avgHeatBlockRampDownRate <- ((lowTemperature-highTemperature-2*deltaTSetPoint)*1000)/(apprxRampDownEndTime-apprxRampDownStartTime)

	#calculate maximum temperature difference between heat block zones during ramp up and down
	maxDeltaTRampUp <- max(abs(temperatureData[(temperatureData$elapsed_time>apprxRampUpStartTime) & (temperatureData$elapsed_time<apprxRampUpEndTime),'heat_block_zone_1_temp']-temperatureData[(temperatureData$elapsed_time>apprxRampUpStartTime) & (temperatureData$elapsed_time<apprxRampUpEndTime),'heat_block_zone_2_temp']))
	maxDeltaTRampDown <- max(abs(temperatureData[(temperatureData$elapsed_time>apprxRampDownStartTime) & (temperatureData$elapsed_time<apprxRampDownEndTime),'heat_block_zone_1_temp']-temperatureData[(temperatureData$elapsed_time>apprxRampDownStartTime) & (temperatureData$elapsed_time<apprxRampDownEndTime),'heat_block_zone_2_temp']))

	#calculate the average ramp rate of the lid heater in degrees C per second
	lidHeaterStartRampTime <- min(temperatureData[(temperatureData$lid_temp>(lowTemperature+deltaTSetPoint)),'elapsed_time'])
	lidHeaterStopRampTime <- max(temperatureData[(temperatureData$lid_temp<(highTemperature-deltaTSetPoint)),'elapsed_time'])
	avgLidHeaterRampUpRate <- ((highTemperature-lowTemperature-2*deltaTSetPoint)*1000)/(lidHeaterStopRampTime-lidHeaterStartRampTime)
	
	return (toJSON(list(Heating=list(AvgRampRate=avgHeatBlockRampUpRate, TotalTime=apprxRampUpEndTime-apprxRampUpStartTime, MaxBlockDeltaT=maxDeltaTRampUp),
						Cooling=list(AvgRampRate=avgHeatBlockRampDownRate*-1, TotalTime=apprxRampDownEndTime-apprxRampDownStartTime, MaxBlockDeltaT=maxDeltaTRampDown),
						Lid=list(HeatingRate=avgLidHeaterRampUpRate, TotalTime=lidHeaterStopRampTime-lidHeaterStartRampTime))))
}
