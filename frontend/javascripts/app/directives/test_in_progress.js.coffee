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

      $scope.completionStatus = null
      $scope.is_holding = false

      updateIsHolding = (data) ->
        $scope.is_holding = TestInProgressHelper.set_holding(data, $scope.experiment)

      updateData = (data) ->

        if (!$scope.completionStatus and (data?.experiment_controller?.machine.state is 'idle' or data?.experiment_controller?.machine.state is 'complete') or !$scope.experiment) and $scope.experimentId
          Experiment.get(id: $scope.experimentId).then (resp) ->
            $scope.data = data
            $scope.completionStatus = resp.experiment.completion_status
            $scope.experiment = resp.experiment
        else
          $scope.data = data

      if Status.getData() then updateData Status.getData()

      $scope.$on 'status:data:updated', (e, data) ->
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