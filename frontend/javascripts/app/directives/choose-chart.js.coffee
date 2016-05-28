###
Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
For more information visit http://www.chaibio.com

Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###
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