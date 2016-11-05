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
    template: '<div></div>'
    # templateUrl: 'app/views/directives/ampli-slider.html'
    link: ($scope, elem, attrs, ngModel) ->

      width = elem.parent().width()
      height = 20
      barHeight = 5
      circleR = 7
      circleStroke = 4
      circleShadowR = circleR + (circleStroke/2) + 0.5

      held = false
      offsetClicked = false
      bgClicked = false
      oldPageX = 0
      oldOffsetWidth = 0
      oldHolderCX = 0
      oldHolderShadowCX = 0

      minOffsetWidth = circleR - circleStroke/2
      maxOffsetWidth = width - circleR * 2

      minCircleCX = circleShadowR
      maxCircleCX = width - (circleR + circleStroke/2) - 1

      $scope.$watch ->
        ngModel.$viewValue
      , (val) ->
        console.log "val: #{val}"
        return if !angular.isNumber(val) or $window.isNaN(val) or held
        width_percent = Math.sqrt(-Math.pow(-val+1, 2)+1)
        newOffsetWidth = width_percent * (maxOffsetWidth - minOffsetWidth)
        newOffsetWidth = newOffsetWidth + minOffsetWidth
        # console.log "newOffsetWidth: #{newOffsetWidth}"
        newHolderCX = newOffsetWidth + (circleR/2)

        if (newOffsetWidth > maxOffsetWidth)
          newOffsetWidth = maxOffsetWidth
        if (newHolderCX > maxCircleCX)
          newHolderCX = maxCircleCX
        if (newOffsetWidth < minOffsetWidth)
          newOffsetWidth = minOffsetWidth
        if (newHolderCX < minCircleCX)
          newHolderCX = minCircleCX


        sliderOffset.attr('width', newOffsetWidth)
        circleHolderShadow.attr('cx', newHolderCX)
        circleHolder.attr('cx', newHolderCX)

      updateModel = (val) ->
        ngModel.$setViewValue(val) if val isnt ngModel.$viewValue
        $scope.$apply()

      moveBy = (px) ->
        newHolderCX = oldHolderCX + px
        newHolderShadowCX = oldHolderShadowCX + px
        newOffsetWidth = oldOffsetWidth + px

        if (newOffsetWidth > maxOffsetWidth)
          newOffsetWidth = maxOffsetWidth
          newHolderShadowCX = maxCircleCX
          newHolderCX = maxCircleCX
        if (newOffsetWidth < minOffsetWidth)
          newOffsetWidth = minOffsetWidth
          newHolderShadowCX = minCircleCX
          newHolderCX = minCircleCX

        sliderOffset.attr('width', newOffsetWidth)
        circleHolderShadow.attr('cx', newHolderShadowCX)
        circleHolder.attr('cx', newHolderCX)

        x = (newOffsetWidth - minOffsetWidth)/(maxOffsetWidth - minOffsetWidth)
        if x < 0
          updateModel(x)
        else
          y = -Math.sqrt(1-Math.pow(x, 2)) + 1
          updateModel(y)

      elem.parent().height(height)

      svg = d3.select(elem[0])
                    .append('svg')
                    .style('width', width)
                    .style('height', height)
                    .attr('alignment-baseline', 'middle')


      sliderBg = svg.append('rect')
                      .attr('fill', '#ccc')
                      .attr('width', width)
                      .attr('height', barHeight)
                      .attr('y', (height)/2 - 2)
                      .attr('rx', 2)
                      .attr('ry', 2)
                      .on 'mousedown', ->
                        bgClicked = true
                        oldHolderCX = circleHolder.attr('cx') * 1
                        oldHolderShadowCX = circleHolderShadow.attr('cx') * 1
                        oldOffsetWidth = sliderOffset.attr('width') * 1
                      .on 'mouseup', ->
                        if bgClicked
                          x = d3.mouse(this)[0] - circleR/2
                          toadd = x - oldOffsetWidth
                          console.log "toadd: #{toadd}"
                          moveBy(toadd)
                          bgClicked = false

      sliderOffset = svg.append('rect')
                      .attr('fill', 'gray')
                      .attr('width', circleR - circleStroke/2)
                      .attr('height', barHeight)
                      .attr('y', (height)/2 - 2)
                      .attr('rx', 2)
                      .attr('ry', 2)
                      .on 'mousedown', ->
                        offsetClicked = true
                        oldHolderCX = circleHolder.attr('cx') * 1
                        oldHolderShadowCX = circleHolderShadow.attr('cx') * 1
                        oldOffsetWidth = sliderOffset.attr('width') * 1
                      .on 'mouseup', ->
                        if offsetClicked
                          x = d3.mouse(this)[0] - circleR/2
                          toadd = x - oldOffsetWidth
                          console.log "toadd: #{toadd}"
                          moveBy(toadd)
                          offsetClicked = false


      circleHolderShadow = svg.append('circle')
                                .attr('fill', '#aaa')
                                .attr('r', circleShadowR )
                                .attr('cy', height/2)
                                .attr('cx', circleShadowR)

      circleHolder = svg.append('circle')
                                .attr('fill', '#8FC742')
                                .attr('stroke', '#fff')
                                .attr('stroke-width', circleStroke)
                                .attr('r', circleR)
                                .attr('cy', height/2)
                                .attr('cx', circleShadowR)

      $window.$(circleHolder.node()).on 'mousedown', (e) ->
        held = true
        oldPageX = e.pageX
        oldHolderCX = circleHolder.attr('cx') * 1
        oldHolderShadowCX = circleHolderShadow.attr('cx') * 1
        oldOffsetWidth = sliderOffset.attr('width') * 1
        TextSelection.disable()

      $window.$(document).on 'mousemove', (e) ->
        if held
          toadd = e.pageX - oldPageX
          moveBy(toadd)

      $window.$(document).on 'mouseup', (e) ->
        TextSelection.enable()
        if held
          held = false
          oldPageX = e.pageX

      # $window.$(sliderBg.node())
      # .on 'mousedown', (e) ->
      #   oldHolderCX = circleHolder.attr('cx') * 1
      #   oldHolderShadowCX = circleHolderShadow.attr('cx') * 1
      #   oldOffsetWidth = sliderOffset.attr('width') * 1
      # .on 'mouseup', (e) ->
      #   toadd = (e.pageX - oldPageX) - (circleR/2)
      #   oldPageX = e.pageX
      #   moveBy(toadd)

      # $window.$(sliderOffset.node())
      # .on 'mousedown', (e) ->
      #   oldHolderCX = circleHolder.attr('cx') * 1
      #   oldHolderShadowCX = circleHolderShadow.attr('cx') * 1
      #   oldOffsetWidth = sliderOffset.attr('width') * 1
      # .on 'mouseup', (e) ->
      #   toadd = (e.pageX - oldPageX) - (circleR/2)
      #   oldPageX = e.pageX
      #   moveBy(toadd)

]);