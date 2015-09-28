window.ChaiBioTech.ngApp.directive 'amplificationWellSwitch', [
  ->
    restrict: 'EA'
    require: 'ngModel'
    templateUrl: 'app/views/directives/amplification-well-switch.html'
    link: ($scope, elem, attrs, ngModel) ->

      $scope.loop = [0..7]
      $scope.buttons = {}

      watchButtons = (val) ->
        ngModel.$setViewValue angular.copy val

      for i in [0..15] by 1
        $scope.buttons["well_#{i}"] =
          selected : true

      $scope.$watch 'buttons', watchButtons, true

]