window.ChaiBioTech.ngApp.service 'TemperatureLogChartHelpers', [
  ->
    @updateData = (temperatureLogsCache, temperatureLogs, resolution, scrollState) ->
      if temperatureLogsCache?.length > 0
        left_et_limit = temperatureLogsCache[temperatureLogsCache.length-1].temperature_log.elapsed_time - (resolution*1000)

        maxScroll = 0
        for temp_log in temperatureLogs
          if temp_log.temperature_log.elapsed_time <= left_et_limit
            ++ maxScroll
          else
            break

        scroll = Math.round (if scrollState is 'FULL' then 1 else scrollState) * maxScroll
        if scrollState < 0 then scroll = 0
        if scrollState > 1 then scroll = maxScroll
        left_et = temperatureLogs[scroll].temperature_log.elapsed_time

        right_et = left_et + (resolution*1000)

        data = _.select temperatureLogs, (temp_log) ->
          et = temp_log.temperature_log.elapsed_time
          et >= left_et and et <= right_et

        return data

    return
]