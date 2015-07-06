# used to display experiment temperature logs chart

window.ChaiBioTech.ngApp

.directive 'temperatureLogChart', [
  'Experiment'
  'ChartData'
  'SecondsDisplay'
  '$interval'
  (Experiment, ChartData, SecondsDisplay, $interval) ->

    restrict: 'AE'
    scope:
      experimentId: '='
    templateUrl: 'app/views/directives/temperature-log-chart.html'
    link: ($scope, elem) ->

      $scope.$watch 'experimentId', (id) =>
        $scope.init() if id

      $scope.init = ->

        $scope.resolutionOptions = [
          10 * 60
          20 * 60
          30 * 60
          60 * 60
          60 * 60 * 24
        ]

        $scope.resolution = $scope.resolutionOptions[0]

        $scope.temperatureLogs = []
        $scope.temperatureLogsCache = []
        $scope.calibration = 100
        $scope.calibrationSize = 100
        $scope.scrollState = 0
        $scope.updateInterval = null

        Experiment
        .getTemperatureData($scope.experimentId, resolution: 1000)
        .success (data) =>
          $scope.temperatureLogsCache = angular.copy data
          $scope.temperatureLogs = angular.copy data
          $scope.updateScale()
          $scope.resizeTemperatureLogs()
          $scope.updateScrollWidth()
          $scope.updateData()

      $scope.updateData = ->
        left_et_limit = $scope.temperatureLogsCache[$scope.temperatureLogsCache.length-1].temperature_log.elapsed_time - ($scope.resolution*1000)

        maxScroll = 0
        for temp_log in $scope.temperatureLogs
          if temp_log.temperature_log.elapsed_time <= left_et_limit
            ++ maxScroll
          else
            break

        scrollState = Math.round $scope.scrollState * maxScroll
        if $scope.scrollState < 0 then scrollState = 0
        if $scope.scrollState > 1 then scrollState = maxScroll
        left_et = $scope.temperatureLogs[scrollState].temperature_log.elapsed_time

        right_et = left_et + ($scope.resolution*1000)

        data = _.select $scope.temperatureLogs, (temp_log) ->
          et = temp_log.temperature_log.elapsed_time
          et >= left_et and et <= right_et

        $scope.updateChart data

      $scope.updateScale = ->
        scales = _.map $scope.temperatureLogsCache, (temp_log) ->
          temp_log = temp_log.temperature_log
          greatest = Math.max.apply Math, [
            parseFloat temp_log.lid_temp
            parseFloat temp_log.heat_block_zone_1_temp
            parseFloat temp_log.heat_block_zone_2_temp
          ]
          greatest

        max_scale = Math.max.apply Math, scales
        $scope.maxY = [0, Math.ceil(max_scale/10)*10]

      $scope.resizeTemperatureLogs = ->
        resolution = $scope.resolution
        if $scope.resolution> $scope.greatest_elapsed_time/1000 then resolution = $scope.greatest_elapsed_time/1000
        chunkSize = Math.round resolution / $scope.calibration
        temperature_logs = angular.copy $scope.temperatureLogsCache
        chunked = _.chunk temperature_logs, chunkSize
        averagedLogs = _.map chunked, (chunk) ->
          elapsed_time_sum = 0
          lid_temp_sum = 0
          heat_block_zone_1_temp_sum = 0
          heat_block_zone_2_temp_sum = 0
          for item in chunk
            elapsed_time_sum += item.temperature_log.elapsed_time
            lid_temp_sum += parseFloat item.temperature_log.lid_temp
            heat_block_zone_1_temp_sum += parseFloat item.temperature_log.heat_block_zone_1_temp
            heat_block_zone_2_temp_sum += parseFloat item.temperature_log.heat_block_zone_2_temp

          temperature_log:
            elapsed_time: Math.round(elapsed_time_sum/chunk.length)
            lid_temp: Math.round(lid_temp_sum/chunk.length*100)/100
            heat_block_zone_1_temp: Math.round(heat_block_zone_1_temp_sum/chunk.length*100)/100
            heat_block_zone_2_temp: Math.round(heat_block_zone_2_temp_sum/chunk.length*100)/100

        averagedLogs.unshift temperature_logs[0]
        averagedLogs.push temperature_logs[temperature_logs.length-1]
        $scope.temperatureLogs = averagedLogs

      $scope.updateScrollWidth = ->

        $scope.greatest_elapsed_time = $scope.temperatureLogsCache[$scope.temperatureLogsCache.length - 1].temperature_log.elapsed_time

        widthPercent = $scope.resolution*1000/$scope.greatest_elapsed_time
        if widthPercent > 1
          widthPercent = 1

        elem.find('.scrollbar').css width: "#{widthPercent*100}%"

      $scope.updateResolution = =>

        if ($scope.resolution)
          $scope.resizeTemperatureLogs()
          $scope.updateScrollWidth()
          $scope.updateData()

        else #view all
          $scope.resolution = $scope.greatest_elapsed_time/1000
          $scope.resizeTemperatureLogs()
          $scope.updateScrollWidth()
          $scope.updateChart angular.copy $scope.temperatureLogs

      $scope.$watch 'scrollState', ->
        if $scope.scrollState and $scope.temperatureLogs
          $scope.updateData()

          if $scope.scrollState >= 1
            $scope.autoUpdateTemperatureLogs()
          else
            $scope.stopInterval()



      $scope.updateChart = (temperature_logs) ->
        data = ChartData.temperatureLogs(temperature_logs).toNVD3()

        $scope.chartData = [
          {
            key: 'Lid Temp'
            values: data.lid_temps
          }
          {
            key: 'Heat Block Zone Temp'
            values: data.heat_block_zone_temps
          }
        ]

      $scope.autoUpdateTemperatureLogs = =>
         if not $scope.updateInterval
          $scope.updateInterval = $interval () ->
            Experiment
            .getTemperatureData($scope.experimentId, resolution: 1000)
            .success (data) ->
              $scope.temperatureLogsCache = angular.copy data
              $scope.temperatureLogs = angular.copy data
              $scope.updateScale()
              $scope.resizeTemperatureLogs()
              $scope.updateScrollWidth()
              $scope.updateData()

          , 1000

      $scope.stopInterval = =>
        $interval.cancel $scope.updateInterval if $scope.updateInterval
        $scope.updateInterval = null

      $scope.optionText = SecondsDisplay.display1

      $scope.xTick = (x) ->
        SecondsDisplay.display2 x/1000

      return

]