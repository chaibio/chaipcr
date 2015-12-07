window.ChaiBioTech.ngApp.controller('ExperimentMenuOverlayCtrl', [
  '$scope'
  '$stateParams'
  'Experiment'
  '$state'
  'AmplificationChartHelper'
  'Status'
  ($scope, $stateParams, Experiment, $state, AmplificationChartHelper, Status) ->
    $scope.params = $stateParams

    $scope.deleteExperiment = ->
      exp = new Experiment id: $stateParams.id
      exp.$delete id: $stateParams.id, ->
        $state.go 'home'

    $scope.$on 'cycle:number:updated', (e, num) ->
      $scope.maxCycle = num

    getExperiment = ->
      Experiment.get(id: $stateParams.id).$promise.then (data) ->
        if !data.experiment.started_at and !data.experiment.completed_at
          $scope.status = 'NOT_STARTED'
        if data.experiment.started_at and !data.experiment.completed_at
          $scope.status = 'RUNNING'
        if data.experiment.started_at and data.experiment.completed_at
          $scope.status = 'COMPLETED'

        $scope.maxCycle = AmplificationChartHelper.getMaxExperimentCycle data.experiment

    getExperiment()

    $scope.$watch ->
      Status.getData()
    , (data, oldData) ->
      state = data?.experiment_controller?.machine?.state
      oldState = oldData?.experiment_controller?.machine?.state
      getExperiment() if state isnt oldState

])
