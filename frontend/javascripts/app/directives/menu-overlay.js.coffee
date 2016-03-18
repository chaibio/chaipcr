window.ChaiBioTech.ngApp.directive 'menuOverlay', [
  '$rootScope'
  '$templateCache'
  '$compile'
  ($rootScope, $templateCache, $compile) ->

    restrict: 'EA'
    transclude: true
    replace: true
    scope:
      sidemenuTemplate: '@'

    templateUrl: 'app/views/directives/menu-overlay.html'
    link: ($scope, elem) ->
      $scope.sideMenuOpen = false

      $rootScope.$on 'sidemenu:toggle', ->
        $scope.sideMenuOpen = !$scope.sideMenuOpen

]
