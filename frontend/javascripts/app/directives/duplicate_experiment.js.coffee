window.ChaiBioTech.ngApp

.directive 'duplicateExperiment', [
  'Experiment'
  '$state'
  '$modal'
  (Experiment, $state, $modal) ->
    restrict: 'EA'
    replace: true
    transclude: true
    scope:
      expId: '=experimentId'
    template: '<div ng-transclude ng-click="copy()"></div>'
    link: ($scope, elem) ->

      body = angular.element('body')

      addClass = ->
        body.addClass 'modal-form'
        body.addClass 'duplicate-experiment'

      removeClass = ->
        body.removeClass 'modal-form'
        body.removeClass 'duplicate-experiment'

      $scope.$on '$destroy', removeClass

      $scope.copy = ->
        addClass()

        modalInstance = $modal.open
          templateUrl: 'app/views/experiment/duplicate-experiment-name-modal.html'

        modalInstance.result.then (exp_name) ->
          copy = Experiment.duplicate($scope.expId, experiment: {name: exp_name})
          copy.success (resp) ->
            $state.go 'edit-protocol', id: resp.experiment.id

          copy.error ->
            alert "Unable to copy experiment!"

        modalInstance.result.catch removeClass

]
