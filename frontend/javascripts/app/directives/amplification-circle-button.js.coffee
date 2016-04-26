window.ChaiBioTech.ngApp
.directive 'amplificationCircleButton', [
  'Device'
  (Device) ->
    restrict: 'EA'
    require: 'ngModel'
    replace: true
    templateUrl: 'app/views/directives/amplification-circle-button.html'
    link: ($scope, elem, attrs, ngModel) ->

      Device.isDualChannel().then (is_dual_channel) ->
        $scope.is_dual_channel = is_dual_channel

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
          paddingLeft: if (!ngModel.$modelValue.ct?[0] and !ngModel.$modelValue.ct?[1]) then '0px' else '10px'

      $scope.toggleState = ->
        state =
          selected: !ngModel.$modelValue.selected || false
          color: ngModel.$modelValue.color || 'gray'
          ct: $scope.ct

        ngModel.$setViewValue state
        $scope.updateUI()

]