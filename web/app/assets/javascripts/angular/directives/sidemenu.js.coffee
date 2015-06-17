window.ChaiBioTech.ngApp

.directive 'SideMenu', [
  ->
    restrict: 'EA'
    replace: true
    templateUrl: 'angular/views/directives/sidemenu.html'
    link: ($scope, elem, attrs) ->

      $scope.open = false

]