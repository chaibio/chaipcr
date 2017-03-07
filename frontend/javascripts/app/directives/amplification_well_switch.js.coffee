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
  (AmplificationChartHelper, $timeout) ->
    restrict: 'EA'
    require: 'ngModel'
    scope:
      colorBy: '='
      buttonLabelsNum: '=?' #numbe of labels in button
      labelUnit: '=?'
    templateUrl: 'app/views/directives/amplification-well-switch.html'
    link: ($scope, elem, attrs, ngModel) ->

      columnCount = 8
      $scope.borders = {};
      $scope.labelUnit = $scope.labelUnit || 'Cq'

      COLORS = AmplificationChartHelper.COLORS

      $scope.loop = [0..7]
      $scope.buttons = {}

      for i in [0..15] by 1
        $scope.buttons["well_#{i}"] =
          selected : true
          color: if ($scope.colorBy is 'well') then COLORS[i] else '#75278E'

      watchButtons = (val) ->
        ngModel.$setViewValue angular.copy val

      $scope.$watchCollection 'buttons', watchButtons

      $scope.$watch 'colorBy', (color_by) ->
        for i in [0..15] by 1
          $scope.buttons["well_#{i}"] = angular.copy $scope.buttons["well_#{i}"]
          $scope.buttons["well_#{i}"].color = if (color_by is 'well') then COLORS[i] else '#75278E'

      $scope.$watchCollection ->
        cts = []
        for i in [0..15] by 1
          cts.push ngModel.$modelValue["well_#{i}"].ct

        return cts

      , (cts) ->
        for ct, i in cts by 1
          $scope.buttons["well_#{i}"].ct = ct if $scope.buttons["well_#{i}"]


      $('#selectableol').selectable(
        'filter': 'li'
        'selected': (evt, ui) ->
          assign($(ui.selected))

        'unselected': (evt, ui) ->
          unAssign($(ui.unselected))
          #$(ui.unselected).find('.circle').click()

        'start': (evt, ui) ->
          if evt.metaKey is false
            $scope.borders = {}

        'stop': (evt, ui) ->
          process();

      );


      removeBorders = (removeIndex) ->
        if $scope.borders[removeIndex + 1]
          $('#box' + (removeIndex + 1)).removeClass('borderLeft')

        if (removeIndex - 1) isnt columnCount and $scope.borders[removeIndex - 1]
          $('#box' + (removeIndex - 1)).removeClass('borderRight')

        if removeIndex <= columnCount and $scope.borders[removeIndex + columnCount]
          $('#box' + (removeIndex + columnCount)).removeClass('borderTop')

        if removeIndex > columnCount and $scope.borders[removeIndex - columnCount]
          $('#box' + (removeIndex - columnCount)).removeClass('borderBottom')


      assign = (node) ->
        id = parseInt $(node).attr('id').replace('box', '')
        if not $scope.borders[id]
          #$(node).find('.circle').click()
          $scope.borders[parseInt(id)] = true;
        else
          removeBorders(id);
          $('#box' + id).removeClass('borderRight borderLeft borderBottom borderTop ui-selected');
          delete $scope.borders[id];


      unAssign = (node) ->
        id = parseInt $(node).attr('id').replace('box', '')
        removeBorders(id);
        $('#box' + id).removeClass('borderRight borderLeft borderBottom borderTop ui-selected');
        delete $scope.borders[id];


      process = () ->
        for id of $scope.borders
          checkRightBorder(parseInt(id));
          checkLeftBorder(parseInt(id));
          checkBottomBorder(parseInt(id));
          checkTopBorder(parseInt(id));

        toggle(boxId) for boxId in [1..16]


      '''toggle = (boxId) ->
        tagId = "#box#{boxId}"
        if $scope.borders[boxId] is true
          if $(tagId).find('.circle').hasClass('selected')
            $(tagId).find('.circle').click()
        else if not $scope.borders[boxId]
          if not $(tagId).find('.circle').hasClass('selected')
            $(tagId).find('.circle').click() '''

      toggle = (boxId) ->
        tagId = "#box#{boxId}"
        alreadySelected = $(tagId).find('.circle').hasClass('selected')
        # At first every rectangle is selected. That means it has selected class.
        # When we select few rectangles we want the rest of them to be unselected. 
        if not $scope.borders[boxId] and alreadySelected
          $(tagId).find('.circle').click()
        else if $scope.borders[boxId] and not alreadySelected
          $(tagId).find('.circle').click()



      checkRightBorder = (id) ->
        if id % columnCount isnt 0 and $scope.borders[id + 1]
          $("#box#{id}").addClass('borderRight')
        else
          $("#box#{id}").removeClass('borderRight')


      checkLeftBorder = (id) ->
        if id isnt columnCount + 1 and $scope.borders[id - 1]
          $("#box#{id}").addClass('borderLeft')
        else
          $("#box#{id}").removeClass('borderLeft')


      checkBottomBorder = (id) ->
        if id < (columnCount + 1) and $scope.borders[id + columnCount]
          $("#box#{id}").addClass('borderBottom')
        else
          $("#box#{id}").removeClass('borderBottom')

      checkTopBorder = (id) ->
        if id > columnCount and $scope.borders[id - columnCount]
          $("#box#{id}").addClass('borderTop');
        else
          $("#box#{id}").removeClass('borderTop');


      $scope.borders[id] = true for id in [1..16]

      $timeout(() ->
          for id of $scope.borders
            $("#box#{id}").addClass('ui-selected')
            checkRightBorder(parseInt(id));
            checkLeftBorder(parseInt(id));
            checkBottomBorder(parseInt(id));
            checkTopBorder(parseInt(id));
        )

]
