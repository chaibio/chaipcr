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
      $scope.is_holding = false

      updateIsHolding = (data) ->
        $scope.is_holding = TestInProgressHelper.set_holding(data, $scope.experiment)

      updateData = (data) ->

        if (!$scope.completionStatus and (data?.experiment_controller?.machine.state is 'idle' or data?.experiment_controller?.machine.state is 'complete') or !$scope.experiment) and $scope.experimentId
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
        $scope.timeRemaining = TestInProgressHelper.timeRemaining(data)

      $scope.barWidth = ->
        if $scope.data and $scope.data.experiment_controller.machine.state is 'running'
          exp = $scope.data.experiment_controller.expriment
          width = exp.run_duration/exp.estimated_duration
          if width > 1 then width = 1

          width
        else
          0

]