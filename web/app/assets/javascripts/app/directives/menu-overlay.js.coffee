window.ChaiBioTech.ngApp.directive 'menuOverlay', [
  '$rootScope'
  '$templateCache'
  '$compile'
  ($rootScope, $templateCache, $compile) ->
    restrict: 'EA'
    transclude: true
    scope:
      sidemenuTemplate: '@'
    templateUrl: 'app/views/directives/menu-overlay.html'
    link: ($scope, elem) ->
      $scope.sideMenuOpen = false
      $scope.sideMenuOptionsOpen = false

      sidemenu = $templateCache.get $scope.sidemenuTemplate
      compiled = $compile(sidemenu)($scope.$parent)
      sidemenuContainer = elem.find('#sidemenu')
      sidemenuContainer.html compiled



      $rootScope.$on 'sidemenu:toggle', ->
        $scope.sideMenuOpen = !$scope.sideMenuOpen
        sidemenuContainer.css minHeight: sidemenuContainer.parent().height()

]