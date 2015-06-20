window.ChaiBioTech.ngApp

.controller 'ExperimentTemperatureLogCtrl', [
  '$scope'
  'Experiment'
  '$stateParams'
  'ChartData'
  ($scope, Experiment, $stateParams, ChartData) ->

    $stateParams.starttime = $stateParams.starttime || 0
    $stateParams.endtime = $stateParams.endtime || (60 * 200 ) # 200 mins

    $scope.options =
      pointDot: false
      datasetFill: false

    $scope.onClick = (points, evt) ->
      console.log(points, evt)

    Experiment.getTemperatureData($stateParams.expId, $stateParams)
    .success (data) ->
      data = ChartData.temperatureLogs.toAngularCharts(data)
      $scope.labels = data.elapsed_time
      $scope.series = ['Heat block zone 1', 'Heat block zone 2', 'Lid']
      $scope.data = [
        data.heat_block_zone_1_temp
        data.heat_block_zone_2_temp
        data.lid_temp
      ]
]