window.ChaiBioTech.ngApp

.directive 'testInProgress', [
  'Status'
  '$interval'
  'Experiment'
  'AmplificationChartHelper'
  'TestInProgressHelper'
  (Status, $interval, Experiment, AmplificationChartHelper, TestInProgressHelper) ->
    restrict: 'EA'
    scope:
      experimentId: '='
    replace: true
    templateUrl: 'app/views/directives/test-in-progress.html'
    link: ($scope, elem) ->

      Status.startSync()
      elem.on '$destroy', ->
        Status.stopSync()
      $scope.completionStatus = null
      $scope.isHolding = false

      updateIsHolding = (data) ->
        $scope.isHolding = TestInProgressHelper.isHolding(data, $scope.experiment)

      updateData = (data) ->

        if (!$scope.completionStatus and (data?.experimentController?.machine.state is 'Idle' or data?.experimentController?.machine.state is 'Complete') or !$scope.experiment) and $scope.experimentId
          TestInProgressHelper.getExperiment($scope.experimentId).then (experiment) ->
            $scope.data = data
            $scope.completionStatus = experiment.completion_status
            $scope.experiment = experiment
        else
          $scope.data = data

      if Status.getData() then updateData Status.getData()

      $scope.$watch ->
        Status.getData()
      , (data) ->
        updateData data
        updateIsHolding data

      $scope.timeRemaining = ->
        if $scope.data and $scope.data.experimentController.machine.state is 'Running'
          exp = $scope.data.experimentController.expriment
          time = (exp.estimated_duration*1+exp.paused_duration*1)-exp.run_duration*1
          if time < 0 then time = 0

          time
        else
          0

      $scope.barWidth = ->
        if $scope.data and $scope.data.experimentController.machine.state is 'Running'
          exp = $scope.data.experimentController.expriment
          width = exp.run_duration/exp.estimated_duration
          if width > 1 then width = 1

          width
        else
          0

]