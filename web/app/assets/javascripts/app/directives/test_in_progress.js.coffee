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

      # // listen on DOM destroy (removal) event, and cancel the next UI update
      # // to prevent updating time after the DOM element was removed.
      elem.on '$destroy', ->
        Status.stopSync()

      $scope.startExperiment = (expId) ->
        Experiment.startExperiment(expId)

      $scope.stopExperiment = ->
        Experiment.stopExperiment()

]