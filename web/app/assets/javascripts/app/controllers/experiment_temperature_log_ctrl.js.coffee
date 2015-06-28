window.ChaiBioTech.ngApp

.controller 'ExperimentTemperatureLogCtrl', [
  '$scope'
  'Experiment'
  '$stateParams'
  'ChartData'
  'SecondsDisplay'
  ($scope, Experiment, $stateParams, ChartData, SecondsDisplay) ->

    @temperatureLogs = []
    @calibration = 10
    @scrollState = 0
    $scope.scrollEnabled = true
    $scope.resolution = 10 * 1000

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
      @scrollState = 0

      if ($scope.resolution)
        Experiment
        .getTemperatureData($stateParams.expId, {resolution: $scope.resolution/@calibration})
        .success (data) =>
          @temperatureLogs = data
          data = angular.copy @temperatureLogs
          data = _.select data, (d) ->
            d.temperature_log.elapsed_time <= $scope.resolution

          @updateScale()
          $scope.scrollState = 0
          @updateChartData data
          $scope.scrollEnabled = true

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

        scrollState = $scope.scrollState

        if $scope.scrollState > @temperatureLogs.length - @calibration
          scrollState = @temperatureLogs.length - @calibration

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

    $scope.resolutionOptions = [
      10 * 1000
      20 * 1000
      30 * 1000 # 30 sec
      60 * 1000 # 1 min
      60 * 1000 * 60  # 1 hour
      60 * 1000 * 60 * 24 # 1 day
    ]

    @optionText = SecondsDisplay.display1

    return

]