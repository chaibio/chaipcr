window.ChaiBioTech.ngApp
.directive 'amplificationCircleButton', [
  ->
    restrict: 'EA'
    require: 'ngModel'
    replace: true
    templateUrl: 'app/views/directives/amplification-chart-button.html'
    link: ($scope, elem, attrs, ngModel) ->

      $scope.$watch ->
        ngModel.$modelValue
      , (newVal) ->
        $scope.updateUI() if newVal

      $scope.updateUI = ->
        $scope.selected = ngModel.$modelValue.selected
        $scope.color = ngModel.$modelValue.color || 'gray'

        $scope.style =
          borderColor: $scope.color

      $scope.toggleState = ->
        state =
          selected: !ngModel.$modelValue.selected || false
          color: ngModel.$modelValue.color || 'gray'

        ngModel.$setViewValue state
        $scope.updateUI()

]