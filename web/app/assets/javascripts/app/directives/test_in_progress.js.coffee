window.ChaiBioTech.ngApp

.directive 'testInProgress', [
  'Status'
  '$interval'
  'Experiment'
  (Status, $interval, Experiment) ->
    restrict: 'EA'
    scope:
      experimentId: '='
    replace: true
    templateUrl: 'app/views/directives/test-in-progress.html'
    link: ($scope, elem) ->

      Status.startSync()

      $scope.$watch ->
        Status.getData()
      , (data) ->
        $scope.data = data

      $scope.timeRemaining = ->
        if $scope.data
          exp = $scope.data.experimentController.expriment
          time = (exp.estimated_duration*1+exp.paused_duration*1)-exp.run_duration*1
          if time < 0 then time = 0

          time
        else
          0

      $scope.barWidth = ->
        if $scope.data
          exp = $scope.data.experimentController.expriment
          width = exp.run_duration/exp.estimated_duration
          if width > 1 then width = 1

          width
        else
          0

      # // listen on DOM destroy (removal) event, and cancel the next UI update
      # // to prevent updating time after the DOM element was removed.
      elem.on '$destroy', ->
        Status.stopSync()

      $scope.startExperiment = (expId) ->
        Experiment.startExperiment(expId)

      $scope.stopExperiment = ->
        Experiment.stopExperiment()

]