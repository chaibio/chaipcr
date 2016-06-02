#load RMySQL library for reading from the database
library(RMySQL)
library(jsonlite)

#constants
deltaTSetPoint <- 1
highTemperature <- 95
lowTemperature <- 50
# xqrm
MIN_AVG_RAMP_RATE <- 2 # C/s
MAX_TOTAL_TIME <- 22.5e3 # ms
MAX_BLOCK_DELTA <- 2 # C
MIN_HEATING_RATE <- 1 # C/s
MAX_TIME_TO_HEAT <- 90e3 # ms


analyze_thermal_performance_diagnostic <- function(db_usr, db_pwd, db_host, db_port, db_name, experiment_id, calibration_id){
    #load chaipcr database
    message("db: ", db_name)
    message("dbuser: ", db_usr)
    message("dbpassword: ", db_pwd)
    message("experiment id: ", experiment_id)

    #load chaipcr database
    dbconn <- dbConnect(RMySQL::MySQL(), user=db_usr, password=db_pwd, host=db_host, port=db_port, dbname=db_name)

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
    
    
    # results
    
    Heating_AvgRampRate <- avgHeatBlockRampUpRate
    Heating_TotalTime <- apprxRampUpEndTime - apprxRampUpStartTime
    Heating_MaxBlockDeltaT <- maxDeltaTRampUp
    Cooling_AvgRampRate <- avgHeatBlockRampDownRate * -1
    Cooling_TotalTime <- apprxRampDownEndTime - apprxRampDownStartTime
    Cooling_MaxBlockDeltaT <- maxDeltaTRampDown
    Lid_HeatingRate <- avgLidHeaterRampUpRate
    Lid_TotalTime <- lidHeaterStopRampTime - lidHeaterStartRampTime
    
    boxed_results <- list(
        Heating=list(
            AvgRampRate=list(Heating_AvgRampRate, Heating_AvgRampRate >= MIN_AVG_RAMP_RATE), 
            TotalTime=list(Heating_TotalTime, Heating_TotalTime <= MAX_TOTAL_TIME), 
            MaxBlockDeltaT=list(Heating_MaxBlockDeltaT, Heating_MaxBlockDeltaT <= MAX_BLOCK_DELTA)
            ),
        Cooling=list(
            AvgRampRate=list(Cooling_AvgRampRate, Cooling_AvgRampRate >= MIN_AVG_RAMP_RATE), 
            TotalTime=list(Cooling_TotalTime, Cooling_TotalTime <= MAX_TOTAL_TIME), 
            MaxBlockDeltaT=list(Cooling_MaxBlockDeltaT, Cooling_MaxBlockDeltaT <= MAX_BLOCK_DELTA)
            ),
        Lid=list(
            HeatingRate=list(Lid_HeatingRate, Lid_HeatingRate >= MIN_HEATING_RATE), 
            TotalTime=list(Lid_TotalTime, Lid_TotalTime <= MAX_TIME_TO_HEAT)
            )
        )
    
    unboxed_results <- lapply(
        boxed_results, 
        function(ele1) lapply(
            ele1, function(ele2) lapply(
                ele2, function(ele3) unbox(ele3))))
    
    return(toJSON(unboxed_results))
}
