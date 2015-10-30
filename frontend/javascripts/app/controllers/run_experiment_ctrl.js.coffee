window.ChaiBioTech.ngApp.controller 'RunExperimentCtrl', [
  '$scope'
  '$stateParams'
  '$state'
  'Experiment'
  ($scope, $stateParams, $state, Experiment) ->
    @chart = $stateParams.chart

    Experiment.get(id: $stateParams.id).$promise.then (data) ->
      Experiment.setCurrentExperiment data.experiment
      $scope.experiment = data.experiment

    @changeChart = (chart) ->
      $state.go 'run-experiment', {id: $stateParams.id, chart: chart}, notify: false
      @chart = chart

]