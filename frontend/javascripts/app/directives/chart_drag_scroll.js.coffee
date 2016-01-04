window.ChaiBioTech.ngApp.directive 'chartDragScroll', [
  '$window'
  'TextSelection'
  ($window, TextSelection) ->
    restrict: 'EA'
    require: 'ngModel'
    link: ($scope, elem, attrs, ngModel) ->

      held = false
      pageX = 0
      oldVal = 0
      elemWith = 0
      $scope.show = false
      $document = ($window).$(document)

      getWidthAttr = ->
        parseInt(elem.attr 'width')

      $document.on 'mousedown', (e) ->
        target_id = $(e.target).closest('.linechart').first().data 'drag-scroll'
        if e.target.tagName is 'rect' and target_id is attrs.id
          held = true
          oldVal = ngModel.$viewValue
          pageX = e.pageX
          TextSelection.disable()
          elemWith = elem.width()

      $document.on 'mousemove', (e) ->
        if held and (oldVal isnt 'FULL')
          xDiff = e.pageX - pageX
          widthattr = getWidthAttr()-elemWith
          valPercent = (xDiff)/widthattr
          val = oldVal+(-valPercent)
          ngModel.$setViewValue val


      $document.on 'mouseup', (e) ->
        held = false
        TextSelection.enable()
]