window.ChaiBioTech.ngApp.controller 'DuplicateExperimentModalCtrl', [
  '$scope'
  'Experiment'
  '$state'
  ($scope, Experiment, $state) ->

    body = angular.element('body')

    addClass = ->
      body.addClass 'modal-form'
      body.addClass 'duplicate-experiment'

    removeClass = ->
      body.removeClass 'modal-form'
      body.removeClass 'duplicate-experiment'

    $scope.newExperimentName = 'New Experiment'
    $scope.focused = false

    addClass()
    $scope.$on '$destroy', removeClass

    $scope.focus = ->
      $scope.focused = true
      $scope.submitted = false
      $scope.error = null
      if $scope.newExperimentName is 'New Experiment'
        $scope.newExperimentName = ''

    $scope.unfocus = ->
      if $scope.newExperimentName is '' or !$scope.newExperimentName
        $scope.focused = false
        $scope.newExperimentName = 'New Experiment'

    $scope.submit = (expName) ->
      $scope.submitted = true
      if $scope.form.$valid and $scope.newExperimentName isnt 'New Experiment'

        $scope.loading = true

        copy = Experiment.duplicate($scope.expId, experiment: {name: expName})
        copy.success (resp) ->
          $state.go 'edit-protocol', id: resp.experiment.id
          $scope.$close()

        copy.error ->
          $scope.error = "Unable to copy experiment!"
          $scope.loading = false

]