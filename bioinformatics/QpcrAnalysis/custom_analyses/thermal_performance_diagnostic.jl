#===============================================================================

    thermal_performance_diagnostic.jl

===============================================================================#

import DataStructures.OrderedDict
import Memento.debug


#===============================================================================
    preset values
===============================================================================#


const deltaTSetPoint    = 1
const highTemperature   = 95
const lowTemperature    = 50
const HIGH_TEMP_mDELTA  = highTemperature - deltaTSetPoint
const LOW_TEMP_pDELTA   = lowTemperature + deltaTSetPoint
const MIN_AVG_RAMP_RATE = 2         ## °C/s
const MAX_TOTAL_TIME    = 22.5e3    ## ms
const MAX_BLOCK_DELTA   = 2         ## °C
const MIN_HEATING_RATE  = 1         ## °C/s
const MAX_TIME_TO_HEAT  = 90e3      ## ms


#===============================================================================
    function definition >>
===============================================================================#


## called by dispatch()
function act(
    ::Type{Val{thermal_performance_diagnostic}},
    req             ::Associative;
    out_format      ::OutputFormat = pre_json_output
    ## remove MySql dependency
    #
    # db_conn ::MySQL.MySQLHandle,
    # exp_id ::Integer, # really used
    # calib_info ::Union{Integer,OrderedDict} ## not used for computation
)
    debug(logger, "at act(::Type{Val{thermal_performance_diagnostic}})")

    ## remove MySql dependency
    #
    # queryTemperatureData = "SELECT * FROM temperature_logs WHERE experiment_id = $exp_id ORDER BY elapsed_time"
    # temperatureData = MySQL.mysql_execute(db_conn, queryTemperatureData)[1]
    # num_dp = length(temperatureData[1]) ## dp = data points

    const elapsed_times = req[ELAPSED_TIME_KEY]
    const num_dp = length(elapsed_times)
    #
    ## add a new column (not row) that is the average of the two heat block zones
    const hbzt_avg =
        map(range(1, num_dp)) do i
            mean(
                map([HEAT_BLOCK_ZONE_1_TEMP_KEY, HEAT_BLOCK_ZONE_2_TEMP_KEY]) do zone
                    req[zone][i]
                end) ## do zone                
        end ## do i
    #
    ## calculate average ramp rates up and down of the heat block
    ## first, calculate the time the heat block reaches the high temperature
    ## this is also the time the ramp up ends and the ramp down starts
    const (apprxRampUpEndTime, apprxRampDownStartTime) =
        extrema(elapsed_times[hbzt_avg .> HIGH_TEMP_mDELTA])
    ## second, calculate the time the ramp up starts and the ramp down ends
    const hbzt_lower = hbzt_avg .< LOW_TEMP_pDELTA
    # const elapsed_times_low_temp  = elapsed_times[hbzt_lower]
    # const apprxRampDownEndTime, apprxRampUpStartTime = extrema(elapsed_times_low_temp)
    const apprxRampUpStartTime =
        try maximum(elapsed_times[hbzt_lower .& (elapsed_times .< apprxRampUpEndTime)])
        catch()
            -Inf_T
        end ## try maximum
    const apprxRampDownEndTime =
        try minimum(elapsed_times[hbzt_lower .& (elapsed_times .> apprxRampDownStartTime)])
        catch()
            Inf_T
        end ## try minimum
    #
    const temp_range_adj = (HIGH_TEMP_mDELTA - LOW_TEMP_pDELTA) * 1000
    #
    ## calculate the average ramp rate up and down in °C per second
    const Heating_TotalTime   = apprxRampUpEndTime   - apprxRampUpStartTime
    const Heating_AvgRampRate = round(temp_range_adj / Heating_TotalTime, JSON_DIGITS)
    const Cooling_TotalTime   = apprxRampDownEndTime - apprxRampDownStartTime
    const Cooling_AvgRampRate = round(temp_range_adj / Cooling_TotalTime, JSON_DIGITS)
    ## calculate maximum temperature difference between heat block zones during ramp up and down
    const Heating_MaxBlockDeltaT, Cooling_MaxBlockDeltaT =
        map((
            [apprxRampUpStartTime,   apprxRampUpEndTime],
            [apprxRampDownStartTime, apprxRampDownEndTime]
        )) do time_vec
            elapsed_time_idc = find(elapsed_times) do elapsed_time
                time_vec[1] < elapsed_time < time_vec[2]
            end ## do elapsed_time
            round(
                maximum(
                    abs.(
                        req[HEAT_BLOCK_ZONE_1_TEMP_KEY][elapsed_time_idc] .-
                            req[HEAT_BLOCK_ZONE_2_TEMP_KEY][elapsed_time_idc])),
                JSON_DIGITS)
        end ## do time_vec
    ## calculate the average ramp rate of the lid heater in degrees °C per second
    const lidHeaterStartRampTime =
        minimum(elapsed_times[
            req[LID_TEMP_KEY] .> LOW_TEMP_pDELTA])
    const lidHeaterStopRampTime =
        maximum(elapsed_times[
            req[LID_TEMP_KEY] .< HIGH_TEMP_mDELTA])
    const Lid_TotalTime = lidHeaterStopRampTime - lidHeaterStartRampTime
    const Lid_HeatingRate = round(temp_range_adj / Lid_TotalTime, JSON_DIGITS)
    #
    const output =
        OrderedDict(
            :Heating => OrderedDict(
                :AvgRampRate    => (Heating_AvgRampRate,    Heating_AvgRampRate    .>= MIN_AVG_RAMP_RATE),
                :TotalTime      => (Heating_TotalTime,      Heating_TotalTime      .<= MAX_TOTAL_TIME),
                :MaxBlockDeltaT => (Heating_MaxBlockDeltaT, Heating_MaxBlockDeltaT .<= MAX_BLOCK_DELTA)
            ),
            :Cooling => OrderedDict(
                :AvgRampRate    => (Cooling_AvgRampRate,    Cooling_AvgRampRate    .>= MIN_AVG_RAMP_RATE),
                :TotalTime      => (Cooling_TotalTime,      Cooling_TotalTime      .<= MAX_TOTAL_TIME),
                :MaxBlockDeltaT => (Cooling_MaxBlockDeltaT, Cooling_MaxBlockDeltaT .<= MAX_BLOCK_DELTA)
            ),
            :Lid => OrderedDict(
                :HeatingRate    => (Lid_HeatingRate, Lid_HeatingRate .>= MIN_HEATING_RATE),
                :TotalTime      => (Lid_TotalTime,   Lid_TotalTime   .<= MAX_TIME_TO_HEAT)
            ),
            :valid => true)
    return output |> out(out_format)
end ## act(::Type{Val{thermal_performance_diagnostic}})
