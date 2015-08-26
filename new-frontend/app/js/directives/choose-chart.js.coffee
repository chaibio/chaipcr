window.ChaiBioTech.ngApp

.directive 'chooseChart', [
  ->
    restrict: 'EA'
    require: '?ngModel'
    templateUrl: 'app/views/directives/choose-chart.html'
    link: ($scope, elem, attrs, ngModel) ->

      $scope.chartTypesData = [
        {
          chartType: 'Amplification Chart',
          buttons:
            A: []
            B: []
        }
        {
          chartType: 'Thermal Profile'
        }
      ]

      $scope.setChartType = (chart) ->
        $scope.selectedChart = chart
        ngModel.$setViewValue chart

      # set default chart type
      $scope.setChartType $scope.chartTypesData[1]

]