window.ChaiBioTech.ngApp.controller 'RunExperimentCtrl', [
  '$scope'
  '$stateParams'
  '$state'
  'Experiment'
  '$uibModal'
  ($scope, $stateParams, $state, Experiment, $uibModal) ->
    @chart = $stateParams.chart
    # $scope.chart = $stateParams.chart
    $scope.hover= ""
    $scope.noofCharts = 2
    $scope.meltCurveChart = false; #if the experiment has a melt curve stage

    $scope.getMeltCurve = () ->
      stages = $scope.experiment.protocol.stages
      return stages.some((val) => val.stage.name is "Melt Curve Stage")

    @changeChart = (chart) ->
      $state.go 'run-experiment', {id: $stateParams.id, chart: chart}, notify: false
      @chart = chart
      $scope.chart = chart
      if $scope.uiModal
        $scope.uiModal.close()

    @changeChartTypeModal = ->

      templateUrl = 'app/views/experiment/choose-chart.html'
      windowClass = 'modal-4-charts'

      if $scope.noofCharts == 3
        templateUrl = 'app/views/experiment/choose-chart-3.html'
        windowClass = 'modal-3-row'
      else if $scope.noofCharts == 2
        windowClass = 'modal-2-row'
        templateUrl = 'app/views/experiment/choose-chart-3.html'

      $scope.uiModal = $uibModal.open({
        templateUrl: templateUrl,
        scope: $scope,
        windowClass: windowClass
      });


    Experiment.get(id: $stateParams.id).then (data) ->
      Experiment.setCurrentExperiment data.experiment
      $scope.experiment = data.experiment
      if $scope.getMeltCurve()
        $scope.meltCurveChart = true;
        $scope.noofCharts = $scope.noofCharts + 1;


]
