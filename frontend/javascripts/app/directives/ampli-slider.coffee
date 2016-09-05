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
      max_offset_width = elem.width()
      max_y = 1
      max_x = 1

      getOffsetWidth = ->
        slider_offset.css('width').replace('px', '')*1

      updateModel = (val) ->
        ngModel.$setViewValue(val) if val isnt ngModel.$modelValue
        $scope.$apply()

      $scope.$watch ->
        ngModel.$viewValue
      , (val) ->
        return if !val or held

        width_percent = Math.sqrt(-Math.pow(-val+1, 2)+1)
        console.log "width_percent: #{width_percent}"
        newWidth = width_percent * max_offset_width
        slider_offset.css('width', "#{newWidth}px")

      elem.on 'mousedown', (e) ->
        held = true
        oldX = e.pageX
        oldWidth = getOffsetWidth()
        TextSelection.disable()
        max_offset_width = elem.width()

      $window.$(document).on 'mousemove', (e) ->
        return if !held
        toadd = (e.pageX - oldX)
        newWidth = (oldWidth*1 + toadd*1)
        slider_offset.css('width', "#{newWidth}px")
        x = newWidth/max_offset_width
        if x < 0
          updateModel(x)
        else
          y = -Math.sqrt(1-Math.pow(x, 2)) + 1
          updateModel(y)

      $window.$(document).on 'mouseup', (e) ->
        held = false
        TextSelection.enable()

]);