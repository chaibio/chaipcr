window.ChaiBioTech.ngApp
.controller 'UserSettingsCtrl', [
  '$scope'
  '$window'
  ($scope, $window) ->

    $scope.goHome = ->
      $window.location = '#home'

]