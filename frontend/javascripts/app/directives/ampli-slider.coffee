window.App.directive('ampliSlider', [
  '$window'
  'TextSelection'
  ($window, TextSelection) ->
    restrict: 'E'
    replace: true
    require: 'ngModel'
    scope:
      cycles: '='
    templateUrl: 'app/views/directives/ampli-slider.html'
    link: ($scope, elem, attrs, ngModel) ->

      hasInit = false
      CYCLES = 0
      ngModel.$setViewValue 0

      init = ->
        hasInit = true

        CYCLES = $scope.cycles-2

        held = false
        oldX = 0
        oldWidth = 0
        newX = 0
        slider_offset = elem.find('.slider-holder-offset')
        slider_width = elem.css('width').replace /px/, ''
        calibration_width = slider_width / CYCLES

        getOffsetWidth = ->
          slider_offset.css('width').replace('px', '')

        updateModel = (num_cycle) ->
          ngModel.$setViewValue(num_cycle)
          $scope.$apply()

        elem.on 'mousedown', (e) ->
          held = true
          oldX = e.pageX
          oldWidth = getOffsetWidth()
          TextSelection.disable()

        $window.$(document).on 'mousemove', (e) ->
          return if !held
          toadd = (e.pageX - oldX)
          newWidth = (oldWidth*1 + toadd*1)
          wRatio = newWidth / slider_width
          wRatio = if wRatio < 0 then 0 else wRatio
          wRatio = if wRatio > 1 then 1 else wRatio
          cycle = Math.floor(wRatio * CYCLES)
          w = cycle * calibration_width
          slider_offset.css('width', w + 'px')
          updateModel cycle

        $window.$(document).on 'mouseup', (e) ->
          held = false
          TextSelection.enable()

      $scope.$watch 'cycles', (cycles) ->
        init() if cycles and !hasInit

]);