window.App.directive('ampliSlider', [
  '$window'
  'TextSelection'
  ($window, TextSelection) ->
    restrict: 'E'
    replace: true
    require: 'ngModel'
    templateUrl: 'app/views/directives/ampli-slider.html'
    link: ($scope, elem, attrs, ngModel) ->

      ngModel.$setViewValue 0

      held = false
      oldX = 0
      oldWidth = 0
      newX = 0
      slider_offset = elem.find('.slider-holder-offset')
      slider_width = elem.css('width').replace /px/, ''

      getOffsetWidth = ->
        slider_offset.css('width').replace('px', '')

      updateModel = ->
        ngModel.$setViewValue(getOffsetWidth()/slider_width);
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
        slider_offset.css('width', newWidth + 'px')
        updateModel()

      $window.$(document).on 'mouseup', (e) ->
        held = false
        TextSelection.enable()

]);