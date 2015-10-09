window.ChaiBioTech.ngApp.controller 'ExperimentNameModalCtrl', [
  '$scope'
  ($scope) ->
    $scope.newExperimentName = 'New Experiment'
    $scope.focused = false

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
        $scope.$close expName

]