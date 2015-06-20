window.ChaiBioTech.ngApp

.controller 'ExperimentTemperatureLogCtrl', [
  '$scope'
  'Experiment'
  '$stateParams'
  ($scope, Experiment, $stateParams) ->

    Experiment.getTemperatureData($stateParams.expId, $stateParams)
    .success (data) ->
      $scope.temperatureData = data
]