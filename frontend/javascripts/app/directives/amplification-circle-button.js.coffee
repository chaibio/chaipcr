window.ChaiBioTech.ngApp
.directive 'amplificationCircleButton', [
  ->
    restrict: 'EA'
    require: 'ngModel'
    replace: true
    templateUrl: 'app/views/directives/amplification-circle-button.html'
    link: ($scope, elem, attrs, ngModel) ->

      $scope.$watchCollection ->
        ngModel.$modelValue
      , (newVal) ->
        $scope.updateUI() if newVal

      $scope.updateUI = ->
        $scope.selected = ngModel.$modelValue.selected
        $scope.color = ngModel.$modelValue.color || 'gray'
        $scope.ct = ngModel.$modelValue.ct

        $scope.style =
          borderColor: $scope.color

      $scope.toggleState = ->
        state =
          selected: !ngModel.$modelValue.selected || false
          color: ngModel.$modelValue.color || 'gray'
          ct: $scope.ct

        ngModel.$setViewValue state
        $scope.updateUI()

]