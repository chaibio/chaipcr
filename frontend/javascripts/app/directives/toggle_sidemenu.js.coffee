window.ChaiBioTech.ngApp

.directive 'toggleSidemenu', [
  '$rootScope',
  ($rootScope) ->

    restrict: 'A'
    scope: {}
    link: ($scope, elem) ->

      elem.on 'click', (e) ->
        $rootScope.$broadcast 'sidemenu:toggle'
        $scope.$apply()

]
