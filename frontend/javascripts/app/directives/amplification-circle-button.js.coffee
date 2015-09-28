window.ChaiBioTech.ngApp
.directive 'amplificationCircleButton', [
  ->
    restrict: 'EA'
    require: 'ngModel'
    replace: true
    template: '<div class="circle noselect" ng-click="toggleState()" ng-style="style">{{text}}</div>'
    link: ($scope, elem, attrs, ngModel) ->

      $scope.$watch ->
        ngModel.$modelValue
      , (newVal) ->
        if newVal
          $scope.updateUI()

      $scope.updateUI = ->
        $scope.style =
          'border-color': angular.copy (ngModel.$modelValue.color || 'gray' )

        if ngModel.$modelValue.selected
          $scope.style.color = ngModel.$modelValue.color || 'gray'
          $scope.text = 'On'
        else
          $scope.style.color = 'gray'
          $scope.text = 'Off'

      $scope.toggleState = ->
        ngModel.$setViewValue
          selected: !ngModel.$modelValue.selected || false
          color: ngModel.$modelValue.color || 'gray'
        $scope.updateUI()

      $scope.updateUI()
]