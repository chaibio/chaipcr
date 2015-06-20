window.ChaiBioTech.ngApp

.controller 'ExpererimentTemperatureLogCtrl', [
  '$scope'
  'Experiment'
  '$stateParams'
  ($scope, Experiment, $stateParams) ->

    console.log $stateParams

    Experiment.getTemperatureData($stateParams.expId, $stateParams)
    .success (data) ->
      console.log data
]