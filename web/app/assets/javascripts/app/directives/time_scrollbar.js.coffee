window.ChaiBioTech.ngApp.directive 'timeScrollbar', [
  '$window'
  ($window) ->
    restrict: 'EA'
    scope:
      max: '='
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

      $scope.$watch 'max', (max) ->
        modelVal = (newMargin/spaceWidth) * $scope.max
        ngModel.$setViewValue Math.round modelVal

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
          scrollbar.css marginLeft: newMargin + 'px'

          modelVal = (newMargin/spaceWidth) * $scope.max
          ngModel.$setViewValue Math.round modelVal

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