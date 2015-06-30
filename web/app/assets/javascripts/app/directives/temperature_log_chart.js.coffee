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
      experiment: '='
    templateUrl: 'app/views/directives/temperature-log-chart.html'
    link: ($scope) ->

      $scope.$watch 'experiment', (exp) =>
        $scope.init() if exp?.id

      RESOLUTIONS =
        tenMins: 10 * 1000
        twentyMins: 20 * 1000
        thirtyMins: 30 * 1000
        oneHour: 60 * 1000 * 60
        oneDay: 60 * 1000 * 60 * 24

      $scope.resolution = RESOLUTIONS.tenMins

      $scope.temperatureLogs = []
      $scope.calibration = 10
      $scope.scrollState = 0
      $scope.scrollEnabled = true
      $scope.resolution = 10 * 1000
      $scope.updateInterval = null

      $scope.options =
        animation: false
        responsive: true
        pointDot: false
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
        $scope.updateResolution()

      $scope.updateScale = =>
        if not $scope.options.scaleStepWidth
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

      $scope.updateResolution = =>

        if ($scope.resolution)
          Experiment
          .getTemperatureData($scope.experiment.id, {resolution: $scope.resolution/$scope.calibration})
          .success (data) =>
            $scope.temperatureLogs = angular.copy data
            data = data.splice 0, $scope.calibration

            $scope.updateScale()
            $scope.updateChartData data
            $scope.scrollEnabled = true
            $scope.updateResolutionOptions()

        else #view all
          Experiment
          .getTemperatureData($scope.experiment.id)
          .success (data) =>
            $scope.temperatureLogs = []
            dataArr = _.chunk data, Math.ceil data.length/$scope.calibration

            for arr, i in dataArr
              $scope.temperatureLogs.push arr[0]
              if i is dataArr.length-1
                $scope.temperatureLogs.push arr[arr.length-1]

            $scope.updateScale()
            $scope.scrollEnabled = false
            $scope.updateChartData angular.copy $scope.temperatureLogs

      $scope.$watch 'scrollState', =>
        if $scope.scrollEnabled

          scrollState = angular.copy $scope.scrollState

          if $scope.scrollState > $scope.temperatureLogs.length - $scope.calibration
            scrollState = $scope.temperatureLogs.length - $scope.calibration
            $scope.autoUpdateTemperatureLogs()
          else
            $scope.stopInterval()

          data = angular.copy $scope.temperatureLogs
          data = data.splice scrollState, $scope.calibration
          $scope.updateChartData data

      $scope.updateChartData = (temperature_logs) =>
        data = ChartData.temperatureLogs.toAngularCharts temperature_logs

        $scope.labels = data.elapsed_time
        $scope.data = [
          data.lid_temp
          data.heat_block_zone_temp
        ]

      $scope.autoUpdateTemperatureLogs = =>
         if not $scope.updateInterval
          $scope.updateInterval = $interval () =>
            Experiment
            .getTemperatureData($scope.experiment.id, {resolution: $scope.resolution/$scope.calibration})
            .success (data) =>
              $scope.temperatureLogs = data
              data = angular.copy $scope.temperatureLogs
              data = data.splice data.length-$scope.calibration, $scope.calibration

              $scope.updateScale()
              $scope.updateChartData data

          , 1000

      $scope.stopInterval = =>
        $interval.cancel $scope.updateInterval if $scope.updateInterval
        $scope.updateInterval = null

      $scope.updateResolutionOptions = =>
        if not $scope.resolutionOptions

          $scope.resolutionOptions = []

          greatest_elapsed_time = 0

          _.each $scope.temperatureLogs, (temp_log) ->
            if temp_log.temperature_log.elapsed_time > greatest_elapsed_time
              greatest_elapsed_time = temp_log.temperature_log.elapsed_time

          if greatest_elapsed_time/RESOLUTIONS.tenMins > $scope.calibration
            $scope.resolutionOptions.push RESOLUTIONS.tenMins

          if greatest_elapsed_time/RESOLUTIONS.twentyMins > $scope.calibration
            $scope.resolutionOptions.push RESOLUTIONS.twentyMins

          if greatest_elapsed_time/RESOLUTIONS.thirtyMins > $scope.calibration
            $scope.resolutionOptions.push RESOLUTIONS.thirtyMins

          if greatest_elapsed_time/RESOLUTIONS.oneHour > $scope.calibration
            $scope.resolutionOptions.push RESOLUTIONS.oneHour

          if greatest_elapsed_time/RESOLUTIONS.oneDay > $scope.calibration
            $scope.resolutionOptions.push RESOLUTIONS.oneDay

      $scope.optionText = SecondsDisplay.display1

      return

]