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
    templateUrl: 'app/views/directives/status-bar.html'
    link: ($scope, elem, attrs) ->

      experiment_id = null

      $scope.show = ->
        if $scope.state isnt 'idle' then (!!$scope.status and !!$scope.footer_experiment) else !!$scope.status

      getExperiment = (cb) ->
        return if !experiment_id
        Experiment.get(id: experiment_id).then (data) ->
          cb data.experiment

      $scope.$watch 'experimentId', (id) ->
        return if !id
        getExperiment (exp) ->
          $scope.footer_experiment = exp

      $scope.is_holding = false

      $scope.$on 'status:data:updated', (e, data, oldData) ->
        return if !data
        return if !data.experiment_controller
        $scope.state = data.experiment_controller.machine.state
        $scope.thermal_state = data.experiment_controller.machine.thermal_state
        $scope.oldState = oldData?.experiment_controller?.machine?.state || 'NONE'

        if ((($scope.oldState isnt $scope.state or !$scope.footer_experiment))) and experiment_id
          getExperiment (exp) ->
            $scope.footer_experiment = exp
            $scope.status = data
            $scope.is_holding = TestInProgressHelper.set_holding(data, exp)
        else
          $scope.status = data
          $scope.is_holding = TestInProgressHelper.set_holding(data, $scope.footer_experiment)

        $scope.timeRemaining = TestInProgressHelper.timeRemaining(data)

        if ($scope.state isnt 'idle' and !experiment_id and data.experiment_controller?.expriment?.id)
          experiment_id = data.experiment_controller.expriment.id
          getExperiment (exp) ->
            $scope.footer_experiment = exp

      $scope.getDuration = ->
        return 0 if !$scope?.experiment?.completed_at
        Experiment.getExperimentDuration($scope.footer_experiment)

      $scope.stopExperiment = ->
        Experiment.stopExperiment($scope.footer_experiment.id)
        .then ->
          $scope.footer_experiment = null

      $scope.resumeExperiment = ->
        Experiment.resumeExperiment($scope.footer_experiment.id)

]
