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
      wells = {}
      $scope.dragging = false

      for b in [0...16] by 1
        wells["well_#{b}"] =
          selected: b > 12
          active: false
          color: COLORS[b]

      ngModel.$setViewValue wells
      $scope.wells = wells

      $scope.row_header_width = 30
      $scope.columns = []
      $scope.rows = []
      for i in [0...8]
        $scope.columns.push index: i, selected: false
      for i in [0...2]
        $scope.rows.push index: i, selected: false

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
          $scope.wells["well_#{i}"].ct = ct if $scope.wells["well_#{i}"]

      $scope.getStyleForWellBar = (row, col, config, i) ->
        'background-color': config.color
        'opacity': if config.selected then 1 else 0.25

      $scope.dragStart = (type, index) ->
        # type can be 'column', 'row', 'well' or 'corner'
        # index is index of the type
        $scope.dragging = true
        $scope.dragStartingPoint =
          type: type
          index: index

        $scope.selected(type, index)

      $scope.dragged = (type, index) ->
        return if !$scope.dragging
        if $scope.dragStartingPoint.type is 'column'
          if type is 'well'
            index = if index >= $scope.columns.length then index - $scope.columns.length else index

          max = Math.max.apply(Math, [index, $scope.dragStartingPoint.index])
          min = if max is index then $scope.dragStartingPoint.index else index
          $scope.columns.forEach (col) ->
            col.selected = col.index >= min and col.index <= max
            $scope.rows.forEach (row) ->
              $scope.wells["well_#{row.index * $scope.columns.length + col.index}"].selected = col.selected

        if $scope.dragStartingPoint.type is 'row'
          if type is 'well'
            index = if index >= 8 then 1 else 0
          max = Math.max.apply(Math, [index, $scope.dragStartingPoint.index])
          min = if max is index then $scope.dragStartingPoint.index else index
          $scope.rows.forEach (row) ->
            row.selected = row.index >= min and row.index <= max
            $scope.columns.forEach (col) ->
              $scope.wells["well_#{row.index * $scope.columns.length + col.index}"].selected = row.selected


      $scope.dragStop = ->
        $scope.dragging = false

        # remove selected from columns and row headers
        $scope.columns.forEach (col) ->
          col.selected = false
        $scope.rows.forEach (row) ->
          row.selected = false

        ngModel.$setViewValue(angular.copy($scope.wells))

]
