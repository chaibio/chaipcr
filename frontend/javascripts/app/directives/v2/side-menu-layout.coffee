window.ChaiBioTech.ngApp.directive 'sideMenuLayout', [
  '$rootScope'
  '$templateCache'
  '$compile'
  '$window'
  ($rootScope, $templateCache, $compile, $window) ->

    restrict: 'EA'
    transclude: true
    #replace: true
    scope:
      isOpen: '=?'

    templateUrl: 'app/views/directives/v2/side-menu-layout.html'
    link: ($scope, elem) ->
      $scope.sideMenuOpen = ($scope.isOpen == undefined) ? true : $scope.isOpen

      $rootScope.$on 'sidemenu:toggle', ->
        $scope.sideMenuOpen = !$scope.sideMenuOpen


      $($window).resize ->
        console.log 'resizing'
]
