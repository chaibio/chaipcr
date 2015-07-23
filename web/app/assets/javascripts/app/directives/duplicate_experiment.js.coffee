window.ChaiBioTech.ngApp

.directive 'duplicateExperiment', [
  'Experiment'
  '$state'
  (Experiment, $state) ->
    restrict: 'EA'
    scope:
      expId: '=experimentId'
    link: ($scope, elem) ->
      $scope.copy = ->
        Experiment.get {id: $scope.expId}, (resp) ->
          copy = Experiment.duplicate($scope.expId, resp)
          copy.success (resp) ->
            $state.go 'runExperiment', id: resp.experiment.id

          copy.error ->
            alert "Unable to copy experiment!"

      elem.click $scope.copy

]