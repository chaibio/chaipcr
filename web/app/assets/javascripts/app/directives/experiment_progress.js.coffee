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
          $scope.expController = angular.copy data.experimentController
          $scope.progressBarWidth = ($scope.expController.expriment.run_duration)/($scope.expController.expriment.estimated_duration+$scope.expController.expriment.paused_duration) * 100
          $scope.progressBarWidth =  if $scope.progressBarWidth < 1 then 1

      update()

      stopTime = $interval update, 1000

      # // listen on DOM destroy (removal) event, and cancel the next UI update
      # // to prevent updating time after the DOM element was removed.
      elem.on '$destroy', ->
        $interval.cancel(stopTime)

]
