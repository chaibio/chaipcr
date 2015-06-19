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
      $scope.data =
        "experiment_name": "MALARIA TEST ALPHA"
        "experiment_stage": "STAGE 3, STEP 2"
        "experiment_time_remaining": "01:13:03"
        "experiment_percentage": "60"

      Status.fetch (data) ->
        $scope.data = data
]
