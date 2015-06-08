window.ChaiBioTech.ngApp
.controller 'UserSettingsCtrl', [
  '$scope'
  '$window'
  ($scope, $window) ->

    $scope.settings = {}

    $scope.goHome = ->
      $window.location = '#home'

]