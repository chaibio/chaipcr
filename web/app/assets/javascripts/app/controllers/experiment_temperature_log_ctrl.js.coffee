window.ChaiBioTech.ngApp

.controller 'ExperimentTemperatureLogCtrl', [
  '$scope'
  'Experiment'
  '$stateParams'
  'ChartData'
  'SecondsDisplay'
  '$interval'
  ($scope, Experiment, $stateParams, ChartData, SecondsDisplay, $interval) ->

    RESOLUTIONS =
      tenMins: 10 * 1000
      twentyMins: 20 * 1000
      thirtyMins: 30 * 1000
      oneHour: 60 * 1000 * 60
      oneDay: 60 * 1000 * 60 * 24

    $scope.resolution = RESOLUTIONS.tenMins

    @temperatureLogs = []
    @calibration = 10
    @scrollState = 0
    $scope.scrollEnabled = true
    $scope.resolution = 10 * 1000
    @updateInterval = null

    $scope.options =
      animation: false
      responsive: true
      pointDot: false
      datasetFill: false
      showTooltips: true
      scaleOverride : true
      scaleSteps: 10
      scaleStartValue : 0

    $scope.series = ['Heat block zone 1 Temp', 'Heat block zone 2 Temp', 'Lid Temp']

    @init = =>
      @updateResolution()

    @updateScale = =>
      if not $scope.options.scaleStepWidth
        scales = _.map @temperatureLogs, (temp_log) ->
          temp_log = temp_log.temperature_log
          greatest = Math.max.apply Math, [
            parseFloat temp_log.lid_temp
            parseFloat temp_log.heat_block_zone_1_temp
            parseFloat temp_log.heat_block_zone_2_temp
          ]
          greatest

        max_scale = Math.max.apply Math, scales

        $scope.options.scaleStepWidth = Math.ceil max_scale/10

    @updateResolution = =>

      if ($scope.resolution)
        Experiment
        .getTemperatureData($stateParams.expId, {resolution: $scope.resolution/@calibration})
        .success (data) =>
          @temperatureLogs = angular.copy data
          data = data.splice 0, @calibration

          @updateScale()
          @updateChartData data
          $scope.scrollEnabled = true
          @updateResolutionOptions()

      else #view all
        Experiment
        .getTemperatureData($stateParams.expId)
        .success (data) =>
          @temperatureLogs = []
          dataArr = _.chunk data, Math.ceil data.length/15

          for arr, i in dataArr
            @temperatureLogs.push arr[0]
            if i is dataArr.length-1
              @temperatureLogs.push arr[arr.length-1]

          @updateScale()
          @updateChartData @temperatureLogs
          $scope.scrollEnabled = false

    $scope.$watch 'scrollState', =>
      if $scope.scrollEnabled

        scrollState = angular.copy $scope.scrollState

        if $scope.scrollState > @temperatureLogs.length - @calibration
          scrollState = @temperatureLogs.length - @calibration
          @autoUpdateTemperatureLogs()
        else
          @stopInterval()

        data = angular.copy @temperatureLogs
        data = data.splice scrollState, @calibration
        @updateChartData data

    @updateChartData = (temperature_logs) =>
      data = ChartData.temperatureLogs.toAngularCharts temperature_logs

      $scope.labels = data.elapsed_time
      $scope.data = [
        data.heat_block_zone_1_temp
        data.heat_block_zone_2_temp
        data.lid_temp
      ]

    @autoUpdateTemperatureLogs = =>
       if not @updateInterval
        @updateInterval = $interval () =>
          Experiment
          .getTemperatureData($stateParams.expId, {resolution: $scope.resolution/@calibration})
          .success (data) =>
            @temperatureLogs = data
            data = angular.copy @temperatureLogs
            data = data.splice data.length-@calibration, @calibration

            @updateScale()
            @updateChartData data

        , 1000

    @stopInterval = =>
      $interval.cancel @updateInterval if @updateInterval
      @updateInterval = null

    @updateResolutionOptions = =>
      if not $scope.resolutionOptions

        $scope.resolutionOptions = []

        greatest_elapsed_time = 0

        _.each @temperatureLogs, (temp_log) ->
          if temp_log.temperature_log.elapsed_time > greatest_elapsed_time
            greatest_elapsed_time = temp_log.temperature_log.elapsed_time

        if greatest_elapsed_time/RESOLUTIONS.tenMins > @calibration
          $scope.resolutionOptions.push RESOLUTIONS.tenMins

        if greatest_elapsed_time/RESOLUTIONS.twentyMins > @calibration
          $scope.resolutionOptions.push RESOLUTIONS.twentyMins

        if greatest_elapsed_time/RESOLUTIONS.thirtyMins > @calibration
          $scope.resolutionOptions.push RESOLUTIONS.thirtyMins

        if greatest_elapsed_time/RESOLUTIONS.oneHour > @calibration
          $scope.resolutionOptions.push RESOLUTIONS.oneHour

        if greatest_elapsed_time/RESOLUTIONS.oneDay > @calibration
          $scope.resolutionOptions.push RESOLUTIONS.oneDay

    @optionText = SecondsDisplay.display1

    return

]