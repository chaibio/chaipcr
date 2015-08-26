window.ChaiBioTech.ngApp

.controller 'RunExperimentCtrl', [
  '$scope'
  '$stateParams'
  'Experiment'
  ($scope, $stateParams, Experiment) ->

    Experiment.get {id: $stateParams.id}, (data) ->
      $scope.experiment = data.experiment
]