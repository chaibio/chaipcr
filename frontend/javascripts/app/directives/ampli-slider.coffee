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
    templateUrl: 'app/views/directives/ampli-slider.html'
    link: ($scope, elem, attrs, ngModel) ->

      held = false
      oldX = 0
      oldWidth = 0
      newX = 0
      slider_offset = elem.find('.slider-holder-offset')
      slider_holder = elem.find('.slider-holder')
      slider_width = 0
      max_offset_width = 0

      getOffsetWidth = ->
        slider_offset.css('width').replace('px', '')

      getHolderWidth = ->
        slider_holder.css('width').replace('px', '')

      getMaxOffsetWidth = ->
        elem.width() - getHolderWidth()*1

      updateModel = (num_cycle) ->
        ngModel.$setViewValue(num_cycle) if num_cycle isnt ngModel.$modelValue
        $scope.$apply()

      $scope.$watch ->
        ngModel.$viewValue
      , (val) ->
        return if !val
        newWidth = val * getMaxOffsetWidth()
        slider_offset.css('width', newWidth + 'px')

      elem.on 'mousedown', (e) ->
        CYCLES = $scope.cycles
        held = true
        oldX = e.pageX
        oldWidth = getOffsetWidth()
        TextSelection.disable()
        slider_width = elem.width()
        max_offset_width = slider_width*1 - getHolderWidth()*1

      $window.$(document).on 'mousemove', (e) ->
        return if !held
        toadd = (e.pageX - oldX)
        newWidth = (oldWidth*1 + toadd*1)
        slider_offset.css('width', newWidth + 'px')
        updateModel newWidth/max_offset_width

      $window.$(document).on 'mouseup', (e) ->
        held = false
        TextSelection.enable()

]);