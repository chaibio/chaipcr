window.App.directive 'sideMenuLayout', [
  '$rootScope'
  '$templateCache'
  '$compile'
  '$window'
  ($rootScope, $templateCache, $compile, $window) ->

    restrict: 'EA'
    transclude: true
    #replace: true
    scope:
      sidemenuTemplate: '@'

    templateUrl: 'dynexp/pika_test/views/v2/directives/side-menu-layout.html'
    link: ($scope, elem) ->
      $scope.sideMenuOpen = true

      $rootScope.$on 'sidemenu:toggle', ->
        $scope.sideMenuOpen = !$scope.sideMenuOpen


      $($window).resize ->
        console.log 'resizing'
]
