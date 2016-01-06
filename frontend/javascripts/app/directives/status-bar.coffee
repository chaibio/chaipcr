window.App.directive 'statusBar', [
  'Experiment'
  '$state'
  'Status'
  'TestInProgressHelper'
  '$rootScope',
  'AmplificationChartHelper',
  (Experiment, $state, Status, TestInProgressHelper, $rootScope, AmplificationChartHelper) ->

    restrict: 'EA'
    replace: true
    scope:
      experimentId: '=?'
    templateUrl: 'app/views/directives/status-bar.html'
    link: ($scope, elem, attrs) ->
      #console.log $scope, "awesome"

      # $scope.$on 'dataLoaded', ->
      $scope.$watch 'experimentId', (newVal, oldVal) ->
        $scope.experimentId = newVal

      $scope.show = ->
        if attrs.experimentId then ($scope.experimentId and $scope.status) else $scope.status

      getExperiment = (cb) ->
        TestInProgressHelper.getExperiment($scope.experimentId).then (experiment) ->
          cb experiment

      $scope.$watch 'experimentId', (id) ->
        return if !id
        getExperiment (exp) ->
          $scope.experiment = exp

      $scope.is_holding = false

      Status.startSync()
      elem.on '$destroy', ->
        Status.stopSync()

      $scope.$watch ->
        Status.getData()
      , (data, oldData) ->
        return if !data
        return if !data.experiment_controller
        $scope.state = data.experiment_controller.machine.state
        $scope.thermal_state = data.experiment_controller.machine.thermal_state
        $scope.oldState = oldData?.experiment_controller?.machine?.state || 'NONE'

        if ((($scope.oldState isnt $scope.state or !$scope.experiment))) and $scope.experimentId
          getExperiment (exp) ->
            $scope.experiment = exp
            $scope.status = data
            $scope.is_holding = TestInProgressHelper.set_holding(data, exp)
        else
          $scope.status = data
          $scope.is_holding = TestInProgressHelper.set_holding(data, $scope.experiment)

        $scope.timeRemaining = TestInProgressHelper.timeRemaining(data)

        if ($scope.state is 'running' and !$scope.experimentId and data.experiment_controller?.expriment?.id)
          $scope.experimentId = data.experiment_controller.expriment.id
          getExperiment (exp) ->
            $scope.experiment = exp

      , true

      $scope.getDuration = ->
        return 0 if !$scope?.experiment?.completed_at
        Experiment.getExperimentDuration($scope.experiment)

      $scope.startExperiment = ->
        Experiment.startExperiment($scope.experimentId).then ->
          $rootScope.$broadcast 'experiment:started', $scope.experimentId
          if $state.is('edit-protocol')
            max_cycle = AmplificationChartHelper.getMaxExperimentCycle($scope.experiment)
            $state.go('run-experiment', {'id': $scope.experimentId, 'chart': 'amplification', 'max_cycle': max_cycle})

      $scope.stopExperiment = ->
        Experiment.stopExperiment($scope.experiment.id)

      $scope.resumeExperiment = ->
        Experiment.resumeExperiment($scope.experiment.id)

]
