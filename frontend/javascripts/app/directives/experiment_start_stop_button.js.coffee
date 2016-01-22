window.ChaiBioTech.ngApp
.directive 'experimentStartStopButton', [
  'Status'
  'Experiment'
  '$rootScope'
  'TestInProgressHelper'
  (Status, Experiment, $rootScope, TestInProgressHelper) ->

    restrict: 'EA'
    replace: true
    scope:
      experimentId: '='
    templateUrl: 'app/views/directives/experiment-start-stop-button.html'
    link: ($scope, elem) ->

      experiment_id = null

      getExperiment = (cb) ->
        cb = cb || angular.noop
        id = experiment_id || $scope.experimentId
        TestInProgressHelper.getExperiment(id).then (exp) ->
          $scope.experiment = exp
          cb()

        Experiment.get {id: id}, (resp) ->
          $scope.experiment = resp.experiment
          cb()

      $scope.$watch 'experimentId', (val) ->
        if angular.isNumber val
          getExperiment $scope.init

      $scope.init = ->

        $scope.$on 'status:data:updated', (e, val) ->
          $scope.data = val
          $scope.state = val?.experiment_controller?.machine.state
          TestInProgressHelper.set_holding(val, $scope.experiment)
          $scope.is_holding = TestInProgressHelper.is_holding()

          if val?.experiment_controller?.expriment?.id and !experiment_id
            experiment_id = val.experiment_controller.expriment.id

        $scope.$watch 'data.experiment_controller.machine.state', (newState, oldState) ->
          if (newState isnt oldState) and (newState is 'idle')
            getExperiment()

      $scope.startExperiment = (expId) ->
        Experiment.startExperiment(expId).then ->
          $rootScope.$broadcast 'experiment:started', expId

      $scope.stopExperiment = ->
        Experiment.stopExperiment().then ->
          getExperiment()

]