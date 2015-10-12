window.ChaiBioTech.ngApp

.directive 'testInProgress', [
  'Status'
  '$interval'
  'Experiment'
  'AmplificationChartHelper'
  (Status, $interval, Experiment, AmplificationChartHelper) ->
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
      $scope.experiment = Experiment.getCurrentExperiment()
      $scope.isHolding = false

      updateIsHolding = (data) ->
        return if !$scope.experiment
        return if !$scope.experiment.protocol
        return if !$scope.experiment.protocol.stages
        return if !data.experimentController
        return if !data.experimentController.expriment
        stages = $scope.experiment.protocol.stages
        steps = stages[stages.length-1].stage.steps
        max_cycle = parseInt(AmplificationChartHelper.getMaxExperimentCycle($scope.experiment))
        duration = parseInt(steps[steps.length-1].step.delta_duration_s)
        current_stage = parseInt(data.experimentController.expriment.stage.number)
        current_step = parseInt(data.experimentController.expriment.step.number)
        current_cycle = parseInt(data.experimentController.expriment.stage.cycle)

        holding = duration is 0 and stages.length is current_stage and steps.length is current_step and current_cycle is max_cycle
        console.log holding
        $scope.isHolding = holding

      updateData = (data) ->

        if !$scope.completionStatus and (data?.experimentController?.machine.state is 'Idle' or data?.experimentController?.machine.state is 'Complete') and $scope.experimentId
          Experiment.get {id: $scope.experimentId}, (exp) ->
            $scope.data = data
            $scope.completionStatus = exp.experiment.completion_status
            $scope.experiment = exp.experiment
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