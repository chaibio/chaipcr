window.ChaiBioTech.ngApp.controller 'CreateExperimentModalCtrl', [
  '$scope'
  'Experiment'
  '$state'
  ($scope, Experiment, $state) ->
    $scope.newExperimentName = 'New Experiment'
    $scope.focused = false
    $scope.loading = false

    $scope.focus = ->
      $scope.focused = true
      $scope.submitted = false
      if $scope.newExperimentName is 'New Experiment'
        $scope.newExperimentName = ''

    $scope.unfocus = ->
      if $scope.newExperimentName is '' or !$scope.newExperimentName
        $scope.focused = false
        $scope.newExperimentName = 'New Experiment'

    $scope.submit = (expName) ->
      $scope.submitted = true
      if $scope.form.$valid and $scope.newExperimentName isnt 'New Experiment'
        # $scope.$close expName

        exp = new Experiment
          experiment:
            name: expName || 'New Experiment'
            protocol: {}

        $scope.loading = true

        exp.$save()
        .then (data) =>
          $scope.$close ->
            $state.go 'edit-protocol', id: data.experiment.id

]