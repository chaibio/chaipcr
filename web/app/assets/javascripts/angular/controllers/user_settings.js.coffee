window.ChaiBioTech.ngApp
.controller 'UserSettingsCtrl', [
  '$scope'
  '$window'
  ($scope, $window) ->

    $scope.settings =
      option: 'A'
      checkbox: true

    $scope.goHome = ->
      $window.location = '#home'

]