window.ChaiBioTech.ngApp
.directive 'amplificationCircleButton', [
  ->
    restrict: 'EA'
    require: 'ngModel'
    replace: true
    template: '<div class="circle noselect" ng-click="toggleState()" ng-style="style">{{text}}</div>'
    link: ($scope, elem, attrs, ngModel) ->

      color = elem.css 'borderColor'
      $scope.state =
        selected: ngModel.$modelValue?.selected || false
        color: ngModel.$modelValue?.color || color

      $scope.$watch ->
        ngModel.$modelValue
      , (newVal) ->
        if angular.isObject newVal
          $scope.state.selected = newVal.selected || false
          $scope.state.color = newVal.color || color
          $scope.updateUI()

      $scope.updateUI = ->
        if $scope.state.selected
          $scope.style = color: color
          $scope.text = 'On'
        else
          $scope.style = color: 'gray'
          $scope.text = 'Off'

      $scope.toggleState = ->
        $scope.state.selected = !$scope.state.selected
        ngModel.$setViewValue $scope.state
        $scope.updateUI()

      $scope.updateUI()

]