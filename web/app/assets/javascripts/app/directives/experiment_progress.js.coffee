window.ChaiBioTech.ngApp

.directive 'experimentProgress', [
  'Status'
  (Status) ->

    restrict: 'EA'
    replace: true
    templateUrl: 'app/views/directives/experiment-progress.html'
    link: ($scope) ->

      Status.fetch().then (data) ->
        $scope.expController = angular.copy data.experimentController
        $scope.progressBarWidth = ($scope.expController.expriment.run_duration)/($scope.expController.expriment.estimated_duration+$scope.expController.expriment.paused_duration) * 100
        # $scope.progressBarWidth =  if $scope.progressBarWidth < 5 then 5
        $scope.progressBarWidth =  50
]
