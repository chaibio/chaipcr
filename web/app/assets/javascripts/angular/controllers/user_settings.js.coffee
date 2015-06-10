window.ChaiBioTech.ngApp
.controller 'UserSettingsCtrl', [
  '$scope'
  '$window'
  ($scope, $window) ->

    $scope.settings = {
      option: 'A'
    }

    $scope.goHome = ->
      $window.location = '#home'

]