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

      $scope.isHolding = false

      Status.startSync()
      elem.on '$destroy', ->
        Status.stopSync()

      $scope.$watch ->
        Status.getData()
      , (data, oldData) ->
        return if !data
        return if !data.experimentController
        $scope.state = data.experimentController.machine.state
        $scope.thermal_state = data.experimentController.machine.thermal_state
        $scope.oldState = oldData?.experimentController?.machine?.state || 'NONE'

        if ((($scope.oldState isnt $scope.state or !$scope.experiment))) and $scope.experimentId
          getExperiment (exp) ->
            $scope.experiment = exp
            $scope.status = data
            $scope.isHolding = TestInProgressHelper.setHolding(data, exp)
        else
          $scope.status = data
          $scope.isHolding = TestInProgressHelper.setHolding(data, $scope.experiment)

        $scope.timeRemaining = TestInProgressHelper.timeRemaining(data)

        if ($scope.state is 'Running' and !attrs.experimentId and data.experimentController?.expriment?.id)
          $scope.experimentId = data.experimentController.expriment.id
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

]