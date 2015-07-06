window.ChaiBioTech.ngApp.directive 'timeScrollbar', [
  '$window'
  ($window) ->
    restrict: 'EA'
    replace: true
    templateUrl: 'app/views/directives/time-scrollbar.html'
    require: 'ngModel'
    link: ($scope, elem, attr, ngModel) ->

      held = false
      oldMargin = 0;
      newMargin = 0;
      pageX = 0
      margin = 0
      spaceWidth = 0
      scaleSize = 0

      scrollbar = elem.find('.scrollbar')

      # respond to change in scrollbar width
      $scope.$watch ->
        scrollbar.css 'width'
      , (newVal, oldVal) ->
        if newVal != oldVal
          oldMargin = getMarginLeft()
          spaceWidth = getSpaceWidth()
          pageX = 0
          updateState 0

      # avoid text selection when dragging the scrollbar
      disableSelect = ->
        $window.$(document.body).css
          'userSelect': 'none'

      enableSelect = ->
        $window.$(document.body).css
          'userSelect': ''

      getMarginLeft = ->
        parseFloat scrollbar.css('marginLeft').replace /px/, ''

      getElemWidth = ->
        parseFloat elem.css('width').replace /px/, ''

      getScrollBarWidth = ->
        parseFloat scrollbar.css('width').replace /px/, ''

      getSpaceWidth = ->
        getElemWidth() - getScrollBarWidth()

      updateState = (ePageX) ->
          xDiff = ePageX - pageX
          newMargin = oldMargin + xDiff
          if newMargin < 0 then newMargin = 0
          if newMargin > spaceWidth then newMargin = spaceWidth
          scrollbar.css marginLeft: "#{newMargin}px"

          # avoid dividing with spaceWidth = 0, else result is NaN
          val = if spaceWidth > 0 then Math.round((oldMargin + xDiff)/spaceWidth*1000)/1000 else 0
          ngModel.$setViewValue val

      elem.on 'mousedown', (e) ->
        held = true
        pageX = e.pageX
        disableSelect()

        oldMargin = getMarginLeft()
        spaceWidth = getSpaceWidth()

      $window.$(document).on 'mouseup', (e) ->
        held = false
        enableSelect()

      $window.$(document).on 'mousemove', (e) ->
        if held
          updateState e.pageX

]