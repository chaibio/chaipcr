window.ChaiBioTech.ngApp.controller 'ExperimentNameModalCtrl', [
  '$scope'
  ($scope) ->
    $scope.newExperimentName = 'New Experiment'
    $scope.focused = false

    $scope.focus = ->
      $scope.focused = true
      if $scope.newExperimentName is 'New Experiment'
        $scope.newExperimentName = ''

    $scope.unfocus = ->
      if $scope.newExperimentName is '' or !$scope.newExperimentName
        $scope.focused = false
        $scope.newExperimentName = 'New Experiment'

]