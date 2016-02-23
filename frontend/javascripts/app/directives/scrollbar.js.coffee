window.ChaiBioTech.ngApp.directive 'scrollbar', [
  '$window'
  'TextSelection'
  ($window, textSelection) ->
    restrict: 'E'
    replace: true
    templateUrl: 'app/views/directives/scrollbar.html'
    scope:
      defaultValue: '='
    require: 'ngModel'
    link: ($scope, elem, attr, ngModel) ->

      held = false
      oldMargin = 0;
      newMargin = 0;
      pageX = 0
      margin = 0
      spaceWidth = 0
      scaleSize = 0
      xDiff = 0

      scrollbar = elem.find('.scrollbar')
      # respond to change in scrollbar width
      $scope.$on 'scrollbar:width:changed', (e, id, percent) ->

        return if id isnt attr.id

        if getSpaceWidth() > 0 and ngModel.$viewValue is 'FULL'
          ngModel.$setViewValue( $scope.defaultValue || 0)

        if ngModel.$viewValue >= 1
          updateMargin(getElemWidth() - getScrollBarWidth())

        spaceWidth = getSpaceWidth()
        if spaceWidth > 0
          if !ngModel.$viewValue
            ngModel.$setViewValue getMarginLeft()/spaceWidth

          newMargin = spaceWidth * ngModel.$viewValue
          updateMargin newMargin

        if !ngModel.$viewValue
          ngModel.$setViewValue($scope.defaultValue || 'FULL')


        if Math.abs(getElemWidth() - getScrollBarWidth()) < 2
          # console.log 'EQUAL!!'
          updateMargin(0)

        console.log ngModel.$viewValue

      # $scope.$watch ->
      #   ngModel.$viewValue
      # , (val, oldVal) ->
      #   if val isnt oldVal and val isnt 'FULL' and !held
      #     val = parseFloat(val) || 0
      #     val = if (val > 1) then 1 else val
      #     val = if (val < 0) then 0 else val

      #     if angular.isNumber val

      #       ngModel.$setViewValue val

      #       newMargin = spaceWidth*val

      #       updateMargin(newMargin)

      getMarginLeft = ->
        parseInt scrollbar.css('marginLeft').replace /px/, ''

      getElemWidth = ->
        parseInt elem.css('width').replace /px/, ''

      getScrollBarWidth = ->
        parseInt scrollbar.css('width').replace /px/, ''

      getSpaceWidth = ->
        getElemWidth() - getScrollBarWidth()

      updateMargin = (newMargin) ->
        if newMargin > spaceWidth then newMargin = spaceWidth
        if newMargin < 0 then newMargin = 0
        scrollbar.css marginLeft: "#{newMargin}px"

      elem.on 'mousedown', (e) ->
        held = true
        pageX = e.pageX
        textSelection.disable()

        oldMargin = getMarginLeft()
        spaceWidth = getSpaceWidth()

      $window.$(document).on 'mouseup', (e) ->
        held = false
        textSelection.enable()

      $window.$(document).on 'mousemove', (e) ->
        if held
          xDiff = e.pageX - pageX
          newMargin = oldMargin + xDiff

          updateMargin newMargin

          # avoid dividing with spaceWidth = 0, else result is NaN
          val = if spaceWidth > 0 then Math.round((newMargin)/spaceWidth*1000)/1000 else 0
          ngModel.$setViewValue val

]