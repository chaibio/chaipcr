window.ChaiBioTech.ngApp
.directive 'experimentStartStopButton', [
  'Status'
  'Experiment'
  '$rootScope'
  (Status, Experiment, $rootScope) ->

    restrict: 'EA'
    replace: true
    scope:
      experimentId: '='
    templateUrl: 'app/views/directives/experiment-start-stop-button.html'
    link: ($scope, elem) ->

      getExperiment = (cb) ->
        cb = cb || angular.noop
        Experiment.get {id: $scope.experimentId}, (resp) ->
          $scope.experiment = resp.experiment
          cb()

      $scope.$watch 'experimentId', (val) ->
        if angular.isNumber val
          getExperiment $scope.init

      $scope.init = ->
        Status.startSync()
        elem.on '$destroy', ->
          Status.stopSync()

        $scope.$watch ->
          Status.getData()
        , (val) ->
          $scope.data = val
          $scope.state = val?.experimentController?.machine.state

        $scope.$watch 'data.experimentController.machine.state', (newState, oldState) ->
          if (newState isnt oldState) and (newState is 'Idle')
            getExperiment()


      $scope.startExperiment = (expId) ->
        Experiment.startExperiment(expId).then ->
          $rootScope.$broadcast 'experiment:started', expId

      $scope.stopExperiment = ->
        Experiment.stopExperiment().then ->
          getExperiment()

]