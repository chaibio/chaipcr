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