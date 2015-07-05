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

      $scope.resolutionOptions = [
        10 * 60
        20 * 60
        30 * 60
        60 * 60
        60 * 60 * 24
      ]

      $scope.resolution = $scope.resolutionOptions[1]

      $scope.temperatureLogs = []
      $scope.calibration = 10
      $scope.calibrationSize = 100
      $scope.scrollState = 0
      $scope.scrollEnabled = true
      $scope.updateInterval = null
      $scope.viewRange = 600

      $scope.options =
        animation: false
        responsive: true
        pointDot: false
        scaleShowHorizontalLines: false
        scaleShowVerticalLines: false
        datasetFill: false
        showTooltips: true
        scaleOverride : true
        scaleSteps: 10
        scaleStartValue : 0

      $scope.series = [
        'Lid Temp'
        'Heat Block Temp'
      ]

      $scope.init = =>
        Experiment
        .getTemperatureData($scope.experimentId, resolution: 1000)
        .success (data) =>
          $scope.temperatureLogs = data
          $scope.updateScale()
          $scope.resolveTemperatureLogs()
          $scope.updateScrollWidth()
          $scope.updateData()

      $scope.updateData = ->
        temperature_logs = angular.copy $scope.temperatureLogs
        left_et_limit = temperature_logs[temperature_logs.length-1].temperature_log.elapsed_time - ($scope.resolution*1000)

        maxScroll = 0
        for temp_log in temperature_logs
          if temp_log.temperature_log.elapsed_time <= left_et_limit
            ++ maxScroll
          else
            break

        scrollState = Math.round $scope.scrollState * maxScroll
        if $scope.scrollState < 0 then scrollState = 0
        if $scope.scrollState > 1 then scrollState = maxScroll
        left_et = temperature_logs[scrollState].temperature_log.elapsed_time

        right_et = left_et + ($scope.resolution*1000)

        data = _.select temperature_logs, (temp_log) ->
          et = temp_log.temperature_log.elapsed_time
          et >= left_et and et <= right_et

        $scope.updateChart data

      $scope.updateScale = =>
        scales = _.map $scope.temperatureLogs, (temp_log) ->
          temp_log = temp_log.temperature_log
          greatest = Math.max.apply Math, [
            parseFloat temp_log.lid_temp
            parseFloat temp_log.heat_block_zone_1_temp
            parseFloat temp_log.heat_block_zone_2_temp
          ]
          greatest

        max_scale = Math.max.apply Math, scales

        $scope.options.scaleStepWidth = Math.ceil max_scale/10

      $scope.resolveTemperatureLogs = ->
        chunkSize = Math.round $scope.temperatureLogs.length/$scope.viewRange
        temperature_logs = angular.copy $scope.temperatureLogs
        chunked = _.chunk (angular.copy temperature_logs), chunkSize
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

        $scope.greatest_elapsed_time = $scope.temperatureLogs[$scope.temperatureLogs.length - 1].temperature_log.elapsed_time

        widthPercent = $scope.resolution*1000/$scope.greatest_elapsed_time
        if widthPercent > 1
          widthPercent = 1

        elem.find('.scrollbar').css width: "#{widthPercent*100}%"

      $scope.updateResolution = =>

        if ($scope.resolution)
          $scope.updateScrollWidth()
          $scope.updateData()

        else #view all
          $scope.resolution = $scope.greatest_elapsed_time/1000
          $scope.updateScrollWidth()
          $scope.updateChart angular.copy $scope.temperatureLogs

      $scope.$watch 'scrollState', ->
        if $scope.scrollState and $scope.temperatureLogs
          $scope.updateData()

          if $scope.scrollState >= 1
            $scope.autoUpdateTemperatureLogs()
          else
            $scope.stopInterval()



      $scope.updateChart = (temperature_logs) =>
        data = ChartData.temperatureLogs(temperature_logs).toAngularCharts()

        $scope.labels = data.elapsed_time
        $scope.data = [
          data.lid_temp
          data.heat_block_zone_temp
        ]

      $scope.autoUpdateTemperatureLogs = =>
         if not $scope.updateInterval
          $scope.updateInterval = $interval () ->
            Experiment
            .getTemperatureData($scope.experimentId, resolution: 1000)
            .success (data) ->
              $scope.temperatureLogs = data
              $scope.updateScale()
              $scope.resolveTemperatureLogs()
              $scope.updateScrollWidth()
              $scope.updateData()

          , 1000

      $scope.stopInterval = =>
        $interval.cancel $scope.updateInterval if $scope.updateInterval
        $scope.updateInterval = null

      $scope.optionText = SecondsDisplay.display1

      return

]