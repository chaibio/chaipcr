###
Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
For more information visit http://www.chaibio.com

Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###
window.ChaiBioTech.ngApp.service 'TemperatureLogService', [
  'SecondsDisplay'
  '$rootScope'
  (SecondsDisplay, $rootScope) ->
    @legend = {}
    @chartConfig =
      axes: {
        x: {
          label: 'Time'
          key: 'elapsed_time'
          ticks: 10
          min: 0
          tickFormat: (t) ->
            SecondsDisplay.display2 t
        },
        y: {
          label: 'Temperature (°C)'
          ticks: 8
          min: 0
          max: 120
          tickFormat: (t) ->
            t = t or 0
            t_string = t.toString().split('.')
            if (t_string[1])
              t = t.toFixed(2)
            return "#{t} °C"

        }
      },
      margin: {
        top: 20
        left: 80
        right: 30
        bottom: 50
      },
      grid:
        x: false
        y: false
      series: [
        {x: 'elapsed_time', dataset: 'dataset', y: 'heat_block_zone_temp', color: '#00AEEF'},
        {x: 'elapsed_time', dataset: 'dataset', y: 'lid_temp', color: '#C5C5C5'}
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
      calibration = 300
      if resolution > greatest_elapsed_time then resolution = greatest_elapsed_time
      chunkSize = Math.round(resolution / calibration)
      chunkSize = if chunkSize > 0 then chunkSize else 1
      temperature_logs = angular.copy data
      chunked = _.chunk temperature_logs, chunkSize
      averagedLogs = _.map chunked, (chunk) ->
        total_lid = 0
        total_heat_block = 0
        total_elapsed_time = 0

        for c in chunk by 1
          total_lid += c.lid_temp
          total_heat_block += c.heat_block_zone_temp
          total_elapsed_time += c.elapsed_time

        return {
          elapsed_time: total_elapsed_time/chunk.length
          lid_temp: total_lid/chunk.length
          heat_block_zone_temp: total_heat_block/chunk.length
        }

      averagedLogs.unshift temperature_logs[0]
      averagedLogs.push temperature_logs[temperature_logs.length-1]
      return averagedLogs

    return
]