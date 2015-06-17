window.ChaiBioTech.ngApp

.controller 'HomeCtrl', [
  '$scope'
  '$rootScope'
  ($scope, $rootScope) ->

    $scope.toggleMenu = ->
      $rootScope.$broadcast 'sidemenu:toggle'
]