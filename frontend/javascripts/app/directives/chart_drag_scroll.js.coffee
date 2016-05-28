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
window.ChaiBioTech.ngApp.directive 'chartDragScroll', [
  '$window'
  'TextSelection'
  ($window, TextSelection) ->
    restrict: 'A'
    require: 'ngModel'
    link: ($scope, elem, attrs, ngModel) ->

      held = false
      pageX = 0
      oldVal = 0
      elemWith = 0
      width_attr = 0
      $scope.show = false
      $document = ($window).$(document)

      getWidthAttr = ->
        parseInt(elem.attr 'width')

      elem.on 'mousedown', (e) ->
        held = true
        oldVal = ngModel.$viewValue
        pageX = e.pageX
        TextSelection.disable()
        y_axis_width = elem.find('g.y.axis').first()[0].getBBox().width
        elemWith = elem.find('svg').first().width() - y_axis_width
        width_attr = getWidthAttr()

      $document.on 'mousemove', (e) ->
        if held and (oldVal isnt 'FULL')
          xDiff = e.pageX - pageX
          width = width_attr-elemWith
          valPercent = xDiff/width
          val = oldVal-valPercent
          ngModel.$setViewValue val


      $document.on 'mouseup', (e) ->
        held = false
        TextSelection.enable()
]