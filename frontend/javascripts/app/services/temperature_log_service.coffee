window.ChaiBioTech.ngApp.service 'TemperatureLogService', [
  'SecondsDisplay'
  '$rootScope'
  (SecondsDisplay, $rootScope) ->
    @legend = {}
    @chartConfig =
      axes: {
        x: {
          key: 'elapsed_time'
          ticks: 10
          min: 0
          tickFormat: (t) ->
            SecondsDisplay.display2 t
        },
        y: {
          min: 0
          max: 120
          tickFormat: (t) ->
            "#{t}°C"
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
        {thickness: '5px',axis: 'y', dataset: 'dataset', interpolation: {mode: 'cardinal', tension: 0.7}, key: 'heat_block_zone_temp', label: 'Heat Block: ', color: '#00AEEF'},
        {thickness: '5px',axis: 'y', dataset: 'dataset', interpolation: {mode: 'cardinal', tension: 0.7}, key: 'lid_temp', label: 'Lid: ', color: '#C5C5C5'}
      ]
      tooltipHook: (domain) =>
        @legend =
          time: SecondsDisplay.display2(domain[0].row.x)
          heat_block: "#{domain[0].row.y1}°C"
          lid: "#{domain[1].row.y1}°C"
        $rootScope.$apply()
        return false

    @moveData = (greatest_elapsed_time, resolution, scrollState) ->
      FIVE_MINS = 60*5
      scroll = (if scrollState is 'FULL' then 1 else (if scrollState < 0 then 0 else (if scrollState > 1 then 1 else scrollState)))
      left_et_limit = (greatest_elapsed_time - resolution)*scroll
      right_et_limit = (left_et_limit + resolution)

      min_x: left_et_limit
      max_x: right_et_limit

    @parseData = (temperature_logs) ->

      temperature_logs = temperature_logs || []

      tmp_logs = []
      max_y = 0

      for temp_log in temperature_logs by 1
        et = temp_log.temperature_log.elapsed_time/1000

        # get heat_block_zone_temp average
        heat_block_temp = (parseFloat(temp_log.temperature_log.heat_block_zone_1_temp)+ parseFloat(temp_log.temperature_log.heat_block_zone_2_temp))/2
        # round to nearest hundreth
        heat_block_temp = Math.round(heat_block_temp*100)/100

        lid_temp = parseFloat temp_log.temperature_log.lid_temp

        tmp_logs.push({
          elapsed_time: et
          heat_block_zone_temp: heat_block_temp
          lid_temp: lid_temp
        })

        max_y = if heat_block_temp > max_y then heat_block_temp else max_y
        max_y = if lid_temp > max_y then lid_temp else max_y

      dataset: tmp_logs
      max_y: max_y

    @reorderData = (temperature_logs) ->
      tmp_logs = _.orderBy angular.copy(temperature_logs), ['elapsed_time'], ['asc']

    @getGreatestElapsedTime = (temperature_logs) ->
      max = 0
      for datum in temperature_logs by 1
        max = if datum.temperature_log.elapsed_time > max then datum.temperature_log.elapsed_time else max
      return max

    @optimizeDataByResolution = (data, resolution, greatest_elapsed_time) ->
      

    return
]