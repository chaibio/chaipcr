window.ChaiBioTech.ngApp

.directive 'duplicateExperiment', [
  'Experiment'
  '$state'
  '$uibModal'
  '$rootScope'
  (Experiment, $state, $uibModal, $rootScope) ->
    restrict: 'EA'
    replace: true
    transclude: true
    scope:
      expId: '=experimentId'
    template: '<div ng-transclude ng-click="copy()"></div>'
    link: ($scope, elem) ->

      $scope.copy = ->
        scope = $rootScope.$new()
        scope.expId = $scope.expId
        $uibModal.open
          templateUrl: 'app/views/experiment/duplicate-experiment-name-modal.html'
          controller: 'DuplicateExperimentModalCtrl'
          scope: scope

]
