window.ChaiBioTech.ngApp.service 'TemperatureLogService', [
  'SecondsDisplay'
  (SecondsDisplay) ->
    @chartConfig =
      axes: {
        x: {
          key: 'elapsed_time'
          ticks: 10
          min: 0
          tickFormat: (t) ->
            SecondsDisplay.display2 t
          # max: 60 * 5
        },
        y: {
          min: 0
        }
      },
      margin: {
        top: 20
        left: 50
        right: 30
      },
      grid:
        x: false
        y: false
      series: [
        {thickness: '5px',axis: 'y', dataset: 'dataset', key: 'heat_block_zone_temp', interpolation: {mode: 'cardinal', tension: 0.7}, color: 'steelblue'},
        {thickness: '5px',axis: 'y', dataset: 'dataset', key: 'lid_temp', interpolation: {mode: 'cardinal', tension: 0.7}, color: 'lightsteelblue'}
      ]

    @moveData = (greatest_elapsed_time, resolution, scrollState) ->
      FIVE_MINS = 60*5
      # greatest_elapsed_time = if greatest_elapsed_time < FIVE_MINS then FIVE_MINS else greatest_elapsed_time
      scroll = (if scrollState is 'FULL' then 1 else (if scrollState < 0 then 0 else (if scrollState > 1 then 1 else scrollState)))
      left_et_limit = (greatest_elapsed_time - resolution)*scroll
      right_et_limit = (left_et_limit + resolution)

      min_x: left_et_limit
      # max_x: if greatest_elapsed_time < FIVE_MINS then (FIVE_MINS) else right_et_limit
      max_x: right_et_limit

    @parseData = (temperature_logs) ->

      temperature_logs = temperature_logs || []

      tmp_logs = []

      for temp_log in temperature_logs by 1
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

      dataset: tmp_logs

    # @mergeNewData = (newTemperatureLogs, oldTemperaturelogs) ->
    #   newTemperatureLogs = newTemperatureLogs || []
    #   oldTemperaturelogs = oldTemperaturelogs || []
    #   return if newTemperatureLogs.length is 0
    #   return newTemperatureLogs if oldTemperaturelogs.length is 0

    #   newData = []
    #   insertionStartIndex = 0
    #   minNewElapsedTime = newTemperatureLogs[1].temperature_log.elapsed_time
    #   minOldElapsedTime = newTemperatureLogs[0].temperature_log.elapsed_time

    #   return oldTemperaturelogs.concat(newTemperatureLogs) if minNewElapsedTime > minOldElapsedTime

    #   for datum, i in oldTemperaturelogs by 1
    #     if datum.temperature_log.elapsed_time > minNewElapsedTime
    #       newData.concat oldTemperaturelogs.slice 0, i-1
    #       newData.concat newTemperatureLogs
    #       newData.concat oldTemperaturelogs.slice i, oldTemperaturelogs.length-1
    #       break

    #   newData

    return
]