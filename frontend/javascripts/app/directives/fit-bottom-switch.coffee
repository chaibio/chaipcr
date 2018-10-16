App.directive 'fitBottomSwitch', [
  'WindowWrapper'
  '$timeout'
  (WindowWrapper, $timeout) ->

    restrict: 'AE',
    scope:
      doc: '=?'
      minHeight: '=?'
      maxHeight: '=?'
      parent: '=?'
    link: ($scope, elem) ->

      elem.addClass 'fit-bottom-switch'
      getHeight = ->
        parentHeight = elem.parent().height()

        siblingHeight = elem.parent().children().get(0).childNodes[1].childNodes[0].clientHeight

        console.log('parentHeight')
        console.log(parentHeight)
        console.log('siblingHeight')
        console.log(siblingHeight)

        height = parentHeight - (siblingHeight + 100 + 10)
        if height < $scope.minHeight 
            height = $scope.minHeight 

        if height > $scope.maxHeight 
            height = $scope.maxHeight 

        height

      set = (height) ->
        height = height || getHeight()
        elem.css('height':  height)
          
      resizeTimeout = null

      $scope.$on 'window:resize', ->
        height = getHeight()
        elem.css(height: '', overflow: 'hidden')
        if resizeTimeout
          $timeout.cancel(resizeTimeout)

        set()
        resizeTimeout = $timeout ->
          elem.css(overflow: '', height: '',)
          set()
          resizeTimeout = null
        , 1000

      if $scope.minHeight > 0
        set($scope.minHeight)
      $timeout(set, 1500)
]