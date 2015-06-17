window.ChaiBioTech.ngApp

.directive 'sideMenu', [
  '$rootScope'
  ($rootScope) ->

    restrict: 'EA'
    replace: true
    scope: {}
    templateUrl: 'angular/views/directives/sidemenu.html'
    link: ($scope, elem, attrs) ->

      $scope.open = false

      $rootScope.$on 'sidemenu:open', ->
        $scope.open = true

      $rootScope.$on 'sidemenu:close', ->
        $scope.open = false

]