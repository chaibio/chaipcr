window.ChaiBioTech.ngApp.directive('exportExperiment', [
  '$window'
  ($window) ->
    restrict: 'AE'
    scope:
      experimentId: '='
    link: ($scope, elem) ->
      elem.click (e) ->
        e.preventDefault()
        $window.location.assign "/experiments/#{$scope.experimentId}/export.zip"
])