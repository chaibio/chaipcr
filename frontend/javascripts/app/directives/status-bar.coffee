window.App.directive 'statusBar', [
  'Experiment'
  'Status'
  'TestInProgressHelper'
  '$rootScope'
  (Experiment, Status, TestInProgressHelper, $rootScope) ->

    restrict: 'EA'
    replace: true
    scope:
      experimentId: '=?'
    templateUrl: 'app/views/directives/status-bar.html'
    link: ($scope, elem, attrs) ->

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
        Experiment.startExperiment($scope.experiment.id).then ->
          $rootScope.$broadcast 'experiment:started', $scope.experimentId

      $scope.stopExperiment = ->
        Experiment.stopExperiment($scope.experiment.id)

      $scope.resumeExperiment = ->
        Experiment.resumeExperiment($scope.experiment.id)

]