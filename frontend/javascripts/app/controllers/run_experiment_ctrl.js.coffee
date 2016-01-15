window.ChaiBioTech.ngApp.controller 'RunExperimentCtrl', [
  '$scope'
  '$stateParams'
  '$state'
  'Experiment'
  '$uibModal'
  ($scope, $stateParams, $state, Experiment, $uibModal) ->
    @chart = $stateParams.chart
    $scope.chart = $stateParams.chart
    $scope.hover= "";
    Experiment.get(id: $stateParams.id).$promise.then (data) ->
      Experiment.setCurrentExperiment data.experiment
      $scope.experiment = data.experiment

    @changeChart = (chart) ->
      $state.go 'run-experiment', {id: $stateParams.id, chart: chart}, notify: false
      @chart = chart
      $scope.chart = chart
      if $scope.uiModal
        $scope.uiModal.close()

    @changeChartTypeModal = ->
      $scope.uiModal = $uibModal.open({
        templateUrl: 'app/views/experiment/choose-chart.html',
        scope: $scope,
      });

]
