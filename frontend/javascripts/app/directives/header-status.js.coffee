window.App.directive 'headerStatus', [
  'Experiment'
  '$state'
  'Status'
  'TestInProgressHelper'
  '$rootScope',
  'AmplificationChartHelper',
  (Experiment, $state, Status, TestInProgressHelper, $rootScope, AmplificationChartHelper) ->

    restrict: 'EA'
    replace: true
    transclude: true
    scope:
      experimentId: '=?'
    templateUrl: 'app/views/directives/header-status.html'
    link: ($scope, elem, attrs) ->

      experiment_id = null

      $scope.$watch 'experimentId', (id) ->
        return if !angular.isNumber id
        experiment_id = id

      $scope.show = ->
        if attrs.experimentId then (experiment_id and $scope.status) else $scope.status

      getExperiment = (cb) ->
        return if !experiment_id
        TestInProgressHelper.getExperiment(experiment_id).then (experiment) ->
          cb experiment

      $scope.$watch 'experimentId', (id) ->
        return if !id
        getExperiment (exp) ->
          $scope.experiment = exp

      $scope.is_holding = false

      $scope.$watch ->
        Status.getData()
      , (data, oldData) ->
        return if !data
        return if !data.experiment_controller
        $scope.state = data.experiment_controller.machine.state
        $scope.thermal_state = data.experiment_controller.machine.thermal_state
        $scope.oldState = oldData?.experiment_controller?.machine?.state || 'NONE'

        if ((($scope.oldState isnt $scope.state or !$scope.experiment))) and experiment_id
          getExperiment (exp) ->
            $scope.experiment = exp
            $scope.status = data
            $scope.is_holding = TestInProgressHelper.set_holding(data, exp)
        else
          $scope.status = data
          $scope.is_holding = TestInProgressHelper.set_holding(data, $scope.experiment)

        $scope.timeRemaining = TestInProgressHelper.timeRemaining(data)

        if ($scope.state isnt 'idle' and !experiment_id and data.experiment_controller?.expriment?.id)
          experiment_id = data.experiment_controller.expriment.id
          getExperiment (exp) ->
            $scope.experiment = exp

      , true

      $scope.getDuration = ->
        return 0 if !$scope?.experiment?.completed_at
        Experiment.getExperimentDuration($scope.experiment)

      $scope.startExperiment = ->
        Experiment.startExperiment(experiment_id).then ->
          $scope.experiment.started_at = true
          getExperiment (exp) ->
            $scope.experiment = exp
            $rootScope.$broadcast 'experiment:started', experiment_id
            if $state.is('edit-protocol')
              max_cycle = AmplificationChartHelper.getMaxExperimentCycle($scope.experiment)
              $state.go('run-experiment', {'id': experiment_id, 'chart': 'amplification', 'max_cycle': max_cycle})

      $scope.stopExperiment = ->
        Experiment.stopExperiment($scope.experiment.id)

      $scope.resumeExperiment = ->
        Experiment.resumeExperiment($scope.experiment.id)

]
