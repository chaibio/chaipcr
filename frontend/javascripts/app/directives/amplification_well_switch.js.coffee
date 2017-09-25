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

window.ChaiBioTech.ngApp.directive 'amplificationWellSwitch', [
  'AmplificationChartHelper',
  '$timeout',
  '$state',
  (AmplificationChartHelper, $timeout) ->
    restrict: 'EA',
    require: 'ngModel',
    scope:
      colorBy: '='
      buttonLabelsNum: '=?' #numbe of labels in button
      labelUnit: '=?'
      chartType: '@'

    templateUrl: 'app/views/directives/amplification-well-switch.html',
    link: ($scope, elem, attrs, ngModel) ->

      COLORS = AmplificationChartHelper.COLORS
      buttons = {}
      $scope.dragging = false

      for b in [0...16] by 1
        buttons["well_#{b}"] =
          selected: b > 12
          active: false
          color: COLORS[b]

      ngModel.$setViewValue buttons
      $scope.buttons = buttons

      $scope.row_header_width = 30
      $scope.columns = [0...8]
      $scope.rows = [0...2]

      $scope.getWidth = -> elem[0].parentElement.offsetWidth
      $scope.getCellWidth = ->
        ($scope.getWidth() - $scope.row_header_width) / $scope.columns.length

      $scope.$watchCollection ->
        cts = []
        for i in [0..15] by 1
          cts.push ngModel.$modelValue["well_#{i}"].ct
        return cts
      , (cts) ->
        for ct, i in cts by 1
          $scope.buttons["well_#{i}"].ct = ct if $scope.buttons["well_#{i}"]

        console.log $scope.buttons

      $scope.getStyleForWellBar = (row, col, config, i) ->
        'background-color': config.color
        'opacity': if config.selected then 1 else 0.25

      $scope.dragStart = ->
        $scope.dragging = true

      $scope.dragStop = ->
        $scope.dragging = false

]
