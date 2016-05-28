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
window.App.directive('ampliSlider', [
  '$window'
  'TextSelection'
  ($window, TextSelection) ->
    restrict: 'E'
    replace: true
    require: 'ngModel'
    scope:
      cycles: '=range'
    templateUrl: 'app/views/directives/ampli-slider.html'
    link: ($scope, elem, attrs, ngModel) ->

      CYCLES = 0
      ngModel.$setViewValue 0

      init = ->
        CYCLES = $scope.cycles
        held = false
        oldX = 0
        oldWidth = 0
        newX = 0
        slider_offset = elem.find('.slider-holder-offset')
        slider_width = 0
        calibration_width = slider_width / CYCLES

        getOffsetWidth = ->
          slider_offset.css('width').replace('px', '')

        updateModel = (num_cycle) ->
          ngModel.$setViewValue(num_cycle) if num_cycle isnt ngModel.$modelValue
          $scope.$apply()

        elem.on 'mousedown', (e) ->
          CYCLES = $scope.cycles
          held = true
          oldX = e.pageX
          oldWidth = getOffsetWidth()
          TextSelection.disable()
          slider_width = elem.width()
          calibration_width = slider_width / CYCLES

        $window.$(document).on 'mousemove', (e) ->
          return if !held
          toadd = (e.pageX - oldX)
          newWidth = (oldWidth*1 + toadd*1)
          wRatio = newWidth / slider_width
          wRatio = if wRatio < 0 then 0 else wRatio
          wRatio = if wRatio > 1 then 1 else wRatio
          cycle = Math.round(wRatio * CYCLES)
          slider_offset_width = cycle * calibration_width
          slider_offset.css('width', slider_offset_width + 'px')
          updateModel cycle

        $window.$(document).on 'mouseup', (e) ->
          held = false
          TextSelection.enable()

      $scope.$watch 'cycles', (cycles) ->
        init() if !!cycles

]);