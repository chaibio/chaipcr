window.ChaiBioTech.ngApp.controller 'AmplificationChartCtrl', [
  '$scope'
  '$stateParams'
  'Experiment'
  ($scope, $stateParams, Experiment) ->

    $scope.buttons =
      A: []
      B: []

    Experiment.get(id: $stateParams.id).$promise.then (data) ->
      $scope.experiment = data.experiment
]
