window.App.directive 'statusBar', [
  'Experiment'
  'Status'
  'TestInProgressHelper'
  (Experiment, Status, TestInProgressHelper) ->

    restrict: 'EA'
    scope:
      experimentId: '='
    templateUrl: 'app/views/directives/status-bar.html'
    link: ($scope, elem, attrs) ->

      Status.startSync()
      elem.on '$destroy', ->
        Status.stopSync()

      $scope.$watch ->
        Status.getData()
      , (data, oldData) ->
        return if !data
        return if !data.experimentController
        $scope.state = data.experimentController.machine.state

        if ((($scope.state is 'Idle' or $scope.state is 'Complete') and oldData?.experimentController?.machine?.state isnt $scope.state)) and $scope.experimentId
          TestInProgressHelper.getExperiment($scope.experimentId).then (experiment) ->
            $scope.status = data
            $scope.experiment = experiment
            console.log experiment
        else
          $scope.status = data

      # , true



]