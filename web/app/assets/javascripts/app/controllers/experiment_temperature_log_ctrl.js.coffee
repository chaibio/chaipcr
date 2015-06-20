window.ChaiBioTech.ngApp

.controller 'ExperimentTemperatureLogCtrl', [
  '$scope'
  'Experiment'
  '$stateParams'
  'ChartData'
  '$state'
  ($scope, Experiment, $stateParams, ChartData, $state) ->

    $scope.options =
      pointDot: false
      datasetFill: false

    updateChart = (opts) ->

      minsRangeToShow = 200
      opts = angular.copy $stateParams
      opts.starttime = opts.starttime || 0
      opts.endtime = opts.endtime || (60 * minsRangeToShow)

      if opts.endtime > (60 * minsRangeToShow)
        opts.starttime = opts.endtime - (60 * minsRangeToShow)

      Experiment
      .getTemperatureData($stateParams.expId, opts)
      .success (data) ->
        data = ChartData.temperatureLogs.toAngularCharts(data)
        $scope.labels = data.elapsed_time
        $scope.series = ['Heat block zone 1', 'Heat block zone 2', 'Lid']
        $scope.data = [
          data.heat_block_zone_1_temp
          data.heat_block_zone_2_temp
          data.lid_temp
        ]

    updateChart($stateParams)

    getElapsedChoices = ->
      $scope.elapsedChoices = []

      Experiment
      .getTemperatureData($stateParams.expId, {starttime: 0})
      .success (data) ->
        elapsedArr = _.map data, (datum) ->
          datum.temperature_log.elapsed_time
        # get the greatest elapsed time
        greatest = Math.max.apply(Math, elapsedArr)
        # get the nth hundreth
        end = Math.ceil(greatest/60)*60
        numMins = end/60

        dividend = Math.ceil(numMins/5)

        end = Math.ceil(numMins/dividend)*dividend

        for i in [dividend..end] by dividend
          $scope.elapsedChoices.push i * 60

        $scope.elapsed = $stateParams.endtime

    getElapsedChoices()

    $scope.elapsedChoices = []
    for i in [200..1000] by 200
      $scope.elapsedChoices.push i * 60

    $scope.elapsedChanged = ->
      $state.go 'expTemperatureLog', {
        expId: $stateParams.expId,
        endtime: $scope.elapsed
      }, notify: false

      $stateParams.endtime = $scope.elapsed

      updateChart()
]