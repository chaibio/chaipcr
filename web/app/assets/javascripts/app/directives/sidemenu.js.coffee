window.ChaiBioTech.ngApp

.directive 'sidemenu', [
  '$rootScope'
  '$templateCache'
  ($rootScope, $templateCache) ->

    restrict: 'EA'
    replace: true
    scope:
      leftMenuTemplate: '='
      $data: '=data'
    templateUrl: 'app/views/directives/sidemenu.html'
    link: ($scope) ->

      $scope.open = false

      $scope.toggle = ->
        $scope.open = !$scope.open

      $rootScope.$on 'sidemenu:open', ->
        $scope.open = true

      $rootScope.$on 'sidemenu:close', ->
        $scope.open = false

      $rootScope.$on 'sidemenu:toggle', ->
        $scope.toggle()

]