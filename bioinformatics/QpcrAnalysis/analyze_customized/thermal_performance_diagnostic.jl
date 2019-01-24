## thermal_performance_diagnostic.jl


function act(
    ::ThermalPerformanceDiagnostic,
    ## remove MySql dependency
    #
    # db_conn ::MySQL.MySQLHandle,
    # exp_id ::Integer, # really used
    # calib_info ::Union{Integer,OrderedDict} # not used for computation
    temperatureData ::Associative;
    out_format      ::Symbol = :pre_json,
    verbose         ::Bool =false
)
    ## remove MySql dependency
    #
    # queryTemperatureData = "SELECT * FROM temperature_logs WHERE experiment_id = $exp_id ORDER BY elapsed_time"
    # temperatureData = MySQL.mysql_execute(db_conn, queryTemperatureData)[1]
    # num_dp = length(temperatureData[1]) # dp = data points

    num_dp = length(temperatureData["elapsed_time"])
    #
    ## add a new column (not row) that is the average of the two heat block zones
    hbzt_avg = map(1:num_dp) do i
        mean(
            map(
                name -> temperatureData[name][i],
                ["heat_block_zone_1_temp", "heat_block_zone_2_temp"]))
    end # do i
    #
    elapsed_times = temperatureData["elapsed_time"]
    #
    ## calculate average ramp rates up and down of the heat block
    ## first, calculate the time the heat block reaches the high temperature/also the time the ramp up ends and the ramp down starts
    elapsed_times_high_temp = elapsed_times[hbzt_avg .> HIGH_TEMP_mDELTA]
    apprxRampUpEndTime, apprxRampDownStartTime = extrema(elapsed_times_high_temp)
    ## second, calculate the time the ramp up starts and the ramp down ends
    elapsed_times_low_temp = elapsed_times[hbzt_avg .< LOW_TEMP_pDELTA]
    apprxRampDownEndTime, apprxRampUpStartTime = extrema(elapsed_times_low_temp)
    #
    hbzt_lower = hbzt_avg .< LOW_TEMP_pDELTA
    apprxRampDownEndTime = try
        minimum(elapsed_times[hbzt_lower .& (elapsed_times .> apprxRampDownStartTime)])
    catch
        Inf
    end # try minimum
    apprxRampUpStartTime = try
        maximum(elapsed_times[hbzt_lower .& (elapsed_times .< apprxRampUpEndTime)])
    catch
        -Inf
    end # try maximum
    #
    temp_range_adj = (HIGH_TEMP_mDELTA - LOW_TEMP_pDELTA) * 1000
    #
    ## calculate the average ramp rate up and down in degrees C per second
    Heating_TotalTime = apprxRampUpEndTime - apprxRampUpStartTime
    Heating_AvgRampRate = temp_range_adj / Heating_TotalTime
    Cooling_TotalTime = apprxRampDownEndTime - apprxRampDownStartTime
    Cooling_AvgRampRate = temp_range_adj / Cooling_TotalTime
    ## calculate maximum temperature difference between heat block zones during ramp up and down
    Heating_MaxBlockDeltaT, Cooling_MaxBlockDeltaT = map((
        [apprxRampUpStartTime, apprxRampUpEndTime],
        [apprxRampDownStartTime, apprxRampDownEndTime]
    )) do time_vec
        elapsed_time_idc = find(elapsed_times) do elapsed_time
            time_vec[1] < elapsed_time < time_vec[2]
        end # find
        maximum(
            abs.(
                temperatureData["heat_block_zone_1_temp"][elapsed_time_idc] .-
                    temperatureData["heat_block_zone_2_temp"][elapsed_time_idc]))
    end # map
    ## calculate the average ramp rate of the lid heater in degrees C per second
    lidHeaterStartRampTime =
        minimum(elapsed_times[
            find(temperatureData["lid_temp"]) do lid_temp
                lid_temp > LOW_TEMP_pDELTA
            end])
    lidHeaterStopRampTime =
        maximum(elapsed_times[
            find(temperatureData["lid_temp"]) do lid_temp
                lid_temp < HIGH_TEMP_mDELTA
            end])
    Lid_TotalTime = lidHeaterStopRampTime - lidHeaterStartRampTime
    Lid_HeatingRate = temp_range_adj / Lid_TotalTime
    #
    results = OrderedDict(
        :Heating => OrderedDict(
            :AvgRampRate    => (Heating_AvgRampRate, Heating_AvgRampRate >= MIN_AVG_RAMP_RATE),
            :TotalTime      => (Heating_TotalTime, Heating_TotalTime <= MAX_TOTAL_TIME),
            :MaxBlockDeltaT => (Heating_MaxBlockDeltaT, Heating_MaxBlockDeltaT <= MAX_BLOCK_DELTA)
        ),
        :Cooling => OrderedDict(
            :AvgRampRate    => (Cooling_AvgRampRate, Cooling_AvgRampRate >= MIN_AVG_RAMP_RATE),
            :TotalTime      => (Cooling_TotalTime, Cooling_TotalTime <= MAX_TOTAL_TIME),
            :MaxBlockDeltaT => (Cooling_MaxBlockDeltaT, Cooling_MaxBlockDeltaT <= MAX_BLOCK_DELTA)
        ),
        :Lid => OrderedDict(
            :HeatingRate    => (Lid_HeatingRate, Lid_HeatingRate >= MIN_HEATING_RATE),
            :TotalTime      => (Lid_TotalTime, Lid_TotalTime <= MAX_TIME_TO_HEAT)
        ),
        :valid => true
    )
    return (out_format == :json) ?
        JSON.json(results) :
        results
end # analyze_thermal_performance_diagnostic()




#
