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

        data

    @toN3LineChart = (temperature_logs) ->

      temperature_logs = temperature_logs || []

      tmp_logs = [];

      for temp_log in temperature_logs
        et = temp_log.temperature_log.elapsed_time/1000

        # get heat_block_zone_temp average
        hbz = (parseFloat(temp_log.temperature_log.heat_block_zone_1_temp)+ parseFloat(temp_log.temperature_log.heat_block_zone_2_temp))/2
        # round to nearest hundreth
        hbz = Math.ceil(hbz*100)/100

        lid_temp = parseFloat temp_log.temperature_log.lid_temp

        tmp_logs.push({
          elapsed_time: et
          heat_block_zone_temp: hbz
          lid_temp: lid_temp
        })

      tmp_logs

    @chartConfig =
      axes: {
        x: {
          key: 'elapsed_time',
          ticksFormatter: (t) ->
            SecondsDisplay.display2 t
          ticks: 8
        },
        y: {
          key: 'heat_block_zone_temp'
          type: 'linear'
          min: 0
          max: 0
        }
      },
      margin: {
        left: 30
      },
      series: [
        {y: 'heat_block_zone_temp', color: 'steelblue'},
        {y: 'lid_temp', color: 'lightsteelblue'}
      ],
      lineMode: 'linear',
      thickness: '2px',
      tension: 0.7,
      tooltip: {
        mode: 'scrubber',
        formatter: (x, y, series) ->
          if series.y is 'lid_temp'
            return "#{SecondsDisplay.display2(x)} | Lid Temp: #{y}"
          else if series.y is 'heat_block_zone_temp'
            return "#{SecondsDisplay.display2(x)} | Heat Block Zone Temp: #{y}"
          else
            return ''
      },
      drawLegend: false,
      drawDots: false,
      hideOverflow: false,
      columnsHGap: 5

    return
]