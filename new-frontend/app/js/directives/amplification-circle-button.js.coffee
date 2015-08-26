window.ChaiBioTech.ngApp
.directive 'amplificationCircleButton', [
  ->
    restrict: 'EA'
    require: 'ngModel'
    replace: true
    template: '<div class="circle" ng-click="toggleState()" ng-style="style">{{text}}</div>'
    link: ($scope, elem, attrs, ngModel) ->

      color = elem.css 'borderColor'

      $scope.state = angular.copy(ngModel.$modelValue) || false

      $scope.updateUI = ->
        if $scope.state
          $scope.style = color: color
          $scope.text = 'On'
        else
          $scope.style = color: 'gray'
          $scope.text = 'Off'

      $scope.toggleState = ->
        $scope.state = !$scope.state
        ngModel.$setViewValue $scope.state
        $scope.updateUI()

      $scope.updateUI()

]