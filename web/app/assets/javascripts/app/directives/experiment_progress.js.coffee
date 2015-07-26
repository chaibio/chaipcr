window.ChaiBioTech.ngApp

.directive 'experimentProgress', [
  'Status'
  '$interval'
  (Status, $interval) ->

    restrict: 'EA'
    replace: true
    templateUrl: 'app/views/directives/experiment-progress.html'
    link: ($scope, elem) ->

      update = ->
        Status.fetch().then (data) ->
          $scope.data = data
          $scope.progressBarWidth = parseFloat(data.experimentController.expriment.run_duration)/parseFloat(data.experimentController.expriment.estimated_duration+parseFloat data.experimentController.expriment.paused_duration) * 100

      update()

      stopTime = $interval update, 1000

      # // listen on DOM destroy (removal) event, and cancel the next UI update
      # // to prevent updating time after the DOM element was removed.
      elem.on '$destroy', ->
        $interval.cancel(stopTime)

]
