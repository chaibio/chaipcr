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

      update = ->
        Status.fetch().then (data) ->
          $scope.data = data

      update()

      timer = $interval update, 1000

      # // listen on DOM destroy (removal) event, and cancel the next UI update
      # // to prevent updating time after the DOM element was removed.
      elem.on '$destroy', ->
        $interval.cancel(timer)

      $scope.startExperiment = (expId) ->
        Experiment.startExperiment(expId)
        .success update

      $scope.stopExperiment = ->
        Experiment.stopExperiment()
        .success update

]