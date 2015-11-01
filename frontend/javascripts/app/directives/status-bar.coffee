window.App.directive 'statusBar', [
  'Experiment'
  'Status'
  'TestInProgressHelper'
  (Experiment, Status, TestInProgressHelper) ->

    restrict: 'EA'
    replace: true
    scope:
      experimentId: '='
    templateUrl: 'app/views/directives/status-bar.html'
    link: ($scope, elem, attrs) ->

      getExperiment = (cb) ->
        TestInProgressHelper.getExperiment($scope.experimentId).then (experiment) ->
          cb experiment

      $scope.$watch 'experimentId', (id) ->
        return if !id
        getExperiment (exp) ->
          $scope.experiment = exp


      Status.startSync()
      elem.on '$destroy', ->
        Status.stopSync()

      $scope.$watch ->
        Status.getData()
      , (data, oldData) ->
        return if !data
        return if !data.experimentController
        $scope.state = data.experimentController.machine.state
        $scope.oldState = oldData?.experimentController?.machine?.state || 'NONE'

        if ((($scope.oldState isnt $scope.state or !$scope.experiment))) and $scope.experimentId
          getExperiment (exp) ->
            $scope.experiment = exp
            $scope.status = data
        else
          $scope.status = data

      , true

      $scope.getDuration = ->
        return 0 if !$scope?.experiment?.completed_at
        Experiment.getExperimentDuration($scope.experiment)

      $scope.startExperiment = ->
        Experiment.startExperiment($scope.experiment.id)

      $scope.stopExperiment = ->
        Experiment.stopExperiment($scope.experiment.id)

]