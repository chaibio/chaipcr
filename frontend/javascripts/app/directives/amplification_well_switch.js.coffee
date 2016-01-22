window.ChaiBioTech.ngApp.directive 'amplificationWellSwitch', [
  'AmplificationChartHelper'
  (AmplificationChartHelper) ->
    restrict: 'EA'
    require: 'ngModel'
    templateUrl: 'app/views/directives/amplification-well-switch.html'
    link: ($scope, elem, attrs, ngModel) ->

      COLORS = AmplificationChartHelper.COLORS

      $scope.loop = [0..7]
      $scope.buttons = {}

      for i in [0..15] by 1
        $scope.buttons["well_#{i}"] =
          selected : true
          color: COLORS[i]

      watchButtons = (val) ->
        ngModel.$setViewValue angular.copy val

      $scope.$watchCollection 'buttons', watchButtons

      $scope.$watchCollection ->
        cts = []
        for i in [0..15] by 1
          cts.push ngModel.$modelValue["well_#{i}"].ct

        return cts

      , (cts) ->
        for ct, i in cts by 1
          $scope.buttons["well_#{i}"].ct = ct if $scope.buttons["well_#{i}"]

]