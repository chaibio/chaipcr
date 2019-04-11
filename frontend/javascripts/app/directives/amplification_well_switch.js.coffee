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

window.ChaiBioTech.ngApp.directive 'chartWellSwitch', [
  'AmplificationChartHelper',
  '$timeout',
  '$state',
  '$rootScope',
  (AmplificationChartHelper, $timeout, $state, $rootScope) ->
    restrict: 'EA',
    require: 'ngModel',
    scope:
      colorBy: '='
      isDual: '='
      samples: '='
      targets: '='
      initSampleColor: '='
      buttonLabelsNum: '=?' #numbe of labels in button
      labelUnit: '=?'
      chartType: '@'

    templateUrl: 'app/views/directives/chart-well-switch.html',
    link: ($scope, elem, attrs, ngModel) ->

      COLORS = AmplificationChartHelper.SAMPLE_TARGET_COLORS
      WELL_COLORS = AmplificationChartHelper.COLORS
      ACTIVE_BORDER_WIDTH = 2
      is_cmd_key_held = false
      wells = {}
      $scope.dragging = false

      $scope.$on 'keypressed:command', ->
        is_cmd_key_held = true

      $scope.$on 'keyreleased:command', ->
        is_cmd_key_held = false

      isCtrlKeyHeld = (evt) ->
        return evt.ctrlKey or is_cmd_key_held

      for b in [0...16] by 1
        if $scope.colorBy is 'well'
          well_color = WELL_COLORS[b]
        else if $scope.colorBy is 'target'
          well_color = if $scope.targets[i] then $scope.targets[i].color else 'transparent'
        else if $scope.colorBy is 'sample'
          well_color = if $scope.samples[i] then $scope.samples[i].color else $scope.initSampleColor
          if ($scope.isDual and !$scope.targets[b*2].id and !$scope.targets[b*2+1].id) or (!$scope.isDual and !$scope.targets[b].id)
            well_color = 'transparent'
        else
          well_color = '#FFFFFF'

        wells["well_#{b}"] =
          selected: true
          active: false
          color: well_color

      ngModel.$setViewValue wells
      $scope.wells = wells

      $scope.row_header_width = 20
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

      $scope.$watchCollection ->
        actives = []
        for i in [0..15] by 1
          actives.push ngModel.$modelValue["well_#{i}"].active
        return actives
      , (actives) ->
        for a, i in actives by 1
          $scope.wells["well_#{i}"].active = a if $scope.wells["well_#{i}"]

      $scope.$watch 'colorBy', (color_by) ->
        for i in [0..15] by 1
          if color_by is 'well'
            well_color = WELL_COLORS[i]
          else if color_by is 'target'
            well_color = if $scope.targets[i] then $scope.targets[i].color else 'transparent'
            $scope.wells["well_#{i}"].color = if $scope.targets[i] then $scope.targets[i].color else 'transparent'
            $scope.wells["well_#{i}"].color1 = if $scope.targets[i*2] then $scope.targets[i*2].color else 'transparent'
            $scope.wells["well_#{i}"].color2 = if $scope.targets[i*2+1] then $scope.targets[i*2+1].color else 'transparent'
          else if color_by is 'sample'
            well_color = if $scope.samples[i] then $scope.samples[i].color else $scope.initSampleColor
            if ($scope.isDual and !$scope.targets[i*2]?.id and !$scope.targets[i*2+1]?.id) or (!$scope.isDual and !$scope.targets[i]?.id)
              well_color = 'transparent'
          # else
          #   well_color = '#75278E'
          else
            well_color = '#FFFFFF'

          selected = true
          if $scope.targets and (($scope.isDual and (!$scope.targets[i*2] or !$scope.targets[i*2].id) and (!$scope.targets[i*2+1] or !$scope.targets[i*2+1].id)) or (!$scope.isDual and (!$scope.targets[i] or !$scope.targets[i].id)))
            selected = false

          # $scope.wells["well_#{i}"].selected = selected
          $scope.wells["well_#{i}"].color = well_color

        ngModel.$setViewValue angular.copy($scope.wells)


      $scope.$watch 'targets', (target) ->
        for i in [0..15] by 1
          selected = true
          if $scope.targets and (($scope.isDual and (!$scope.targets[i*2] or !$scope.targets[i*2].id) and (!$scope.targets[i*2+1] or !$scope.targets[i*2+1].id)) or (!$scope.isDual and (!$scope.targets[i] or !$scope.targets[i].id)))
            selected = false
          $scope.wells["well_#{i}"].selected = selected
        ngModel.$setViewValue angular.copy($scope.wells)

      $scope.getStyleForWellBar = (row, col, config, i) ->
        'background-color': config.color
        'opacity': if config.selected then 1 else 0.25

      $scope.getStyleForTarget1Bar = (row, col, config, i) ->
        'background-color': config.color1
        'opacity': if config.selected then 1 else 0.25

      $scope.getStyleForTarget2Bar = (row, col, config, i) ->
        'background-color': config.color2
        'opacity': if config.selected then 1 else 0.25

      $scope.dragStart = (evt, type, index) ->
        # type can be 'column', 'row', 'well' or 'corner'
        # index is index of the type
        $scope.dragging = true
        $scope.dragStartingPoint =
          type: type
          index: index

        #$scope.dragged(evt, type, index)

      $scope.dragged = (evt, type, index) ->
        return if !$scope.dragging
        return if type is $scope.dragStartingPoint.type and index is $scope.dragStartingPoint.index

        if $scope.dragStartingPoint.type is 'column'
          if type is 'well'
            index = if index >= $scope.columns.length then index - $scope.columns.length else index

          max = Math.max.apply(Math, [index, $scope.dragStartingPoint.index])
          min = if max is index then $scope.dragStartingPoint.index else index
          $scope.columns.forEach (col) ->
            col.selected = col.index >= min and col.index <= max
            $scope.rows.forEach (row) ->
              well = $scope.wells["well_#{row.index * $scope.columns.length + col.index}"]
              if not (isCtrlKeyHeld(evt) and well.selected)
                well.selected = col.selected

        if $scope.dragStartingPoint.type is 'row'
          if type is 'well'
            index = if index >= 8 then 1 else 0
          max = Math.max.apply(Math, [index, $scope.dragStartingPoint.index])
          min = if max is index then $scope.dragStartingPoint.index else index
          $scope.rows.forEach (row) ->
            row.selected = row.index >= min and row.index <= max
            $scope.columns.forEach (col) ->
              well = $scope.wells["well_#{row.index * $scope.columns.length + col.index}"]
              # ctrl or command key held
              if not (isCtrlKeyHeld(evt) and well.selected)
                well.selected = row.selected

        if $scope.dragStartingPoint.type is 'well'
          if type is 'well'
            row1 = Math.floor($scope.dragStartingPoint.index / $scope.columns.length)
            col1 = $scope.dragStartingPoint.index - row1 * $scope.columns.length
            row2 = Math.floor(index / $scope.columns.length)
            col2 = index - row2 * $scope.columns.length
            max_row = Math.max.apply(Math, [row1, row2])
            min_row = if max_row is row1 then row2 else row1
            max_col = Math.max.apply(Math, [col1, col2])
            min_col = if max_col is col1 then col2 else col1
            $scope.rows.forEach (row) ->
              $scope.columns.forEach (col) ->
                selected = (row.index >= min_row and row.index <= max_row) and (col.index >= min_col and col.index <= max_col)
                well = $scope.wells["well_#{row.index * $scope.columns.length + col.index}"]
                if not (isCtrlKeyHeld(evt) and well.selected)
                  well.selected = selected


      $scope.dragStop = (evt, type, index) ->

        $scope.dragging = false

        # remove selected from columns and row headers
        $scope.columns.forEach (col) ->
          col.selected = false
        $scope.rows.forEach (row) ->
          row.selected = false

        if type is 'well' and index is $scope.dragStartingPoint.index
          # deselect all other wells if ctrl/cmd key is not held
          if !isCtrlKeyHeld(evt)
            $scope.rows.forEach (r) ->
              $scope.columns.forEach (c) ->
                $scope.wells["well_#{r.index * $scope.columns.length + c.index}"].selected = false

          # toggle selected state
          well = $scope.wells["well_#{index}"]
          well.selected = if isCtrlKeyHeld(evt) then !well.selected else true

        ngModel.$setViewValue(angular.copy($scope.wells))

        $rootScope.$broadcast 'event:switch-chart-well', {active: well?.active, index: index}

      $scope.getWellStyle = (row, col, well, index) ->
        return {} if well.active

        well_left_index = if (col.index + 1) % $scope.columns.length is 1 then null else index - 1
        well_right_index = if (col.index + 1) % $scope.columns.length is 0 then null else index + 1
        well_top_index = if (row.index + 1) % $scope.rows.length is 1 then null else index - $scope.columns.length
        well_bottom_index = if (row.index + 1) % $scope.rows.length is 0 then null else index + $scope.columns.length

        well_left = $scope.wells["well_#{well_left_index}"]
        well_right = $scope.wells["well_#{well_right_index}"]
        well_top = $scope.wells["well_#{well_top_index}"]
        well_bottom = $scope.wells["well_#{well_bottom_index}"]

        style = {}
        border = '1px solid #000'
        if well.selected
          if !(well_left?.selected)
            style['border-left'] = border
          if !(well_right?.selected)
            style['border-right'] = border
          if !(well_top?.selected)
            style['border-top'] = border
          if !(well_bottom?.selected)
            style['border-bottom'] = border

        return style

      $scope.getWellContainerStyle = (row, col, well, i) ->
        style = {}
        if well.active && well.selected
          style.width = "#{Math.round(@getCellWidth() + ACTIVE_BORDER_WIDTH * 4)}px"
        return style

      $scope.displayCt = (ct) ->
        if ct and angular.isNumber(ct * 1) and !window.isNaN(ct * 1)
          parseFloat(ct).toFixed(2)
        else
          ''

  ]
