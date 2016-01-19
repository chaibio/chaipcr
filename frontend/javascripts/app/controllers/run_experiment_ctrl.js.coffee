window.ChaiBioTech.ngApp.controller 'RunExperimentCtrl', [
  '$scope'
  '$stateParams'
  '$state'
  'Experiment'
  '$uibModal'
  ($scope, $stateParams, $state, Experiment, $uibModal) ->
    @chart = $stateParams.chart
    $scope.chart = $stateParams.chart
    $scope.hover= ""
    $scope.noofCharts = 3

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
      if $scope.noofCharts < 4
        templateUrl = 'app/views/experiment/choose-chart-3.html'
      else
        templateUrl = 'app/views/experiment/choose-chart.html'


      $scope.uiModal = $uibModal.open({
        templateUrl: templateUrl,
        scope: $scope,
        windowClass: 'modal-1-row'
      });

]
