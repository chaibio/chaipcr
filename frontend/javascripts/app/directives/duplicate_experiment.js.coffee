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
        copy = Experiment.duplicate($scope.expId)
        copy.success (resp) ->
          $state.go 'edit-protocol', id: resp.experiment.id

        copy.error ->
          alert "Unable to copy experiment!"

      elem.click $scope.copy

]
