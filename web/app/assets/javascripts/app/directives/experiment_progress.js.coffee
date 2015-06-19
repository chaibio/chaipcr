window.ChaiBioTech.ngApp

.directive 'experimentProgress', [
  'Status'
  (Status) ->

    restrict: 'EA'
    scope: {
      test: '='
    }
    replace: true
    templateUrl: 'app/views/directives/experiment-progress.html'
    link: ($scope) ->

      Status.fetch (data) ->
        $scope.data = data
]