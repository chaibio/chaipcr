App.directive 'aspectRatio', [
  'WindowWrapper'
  '$timeout'
  (WindowWrapper, $timeout) ->

    restrict: 'AE',
    scope:
      offsetX: '=?'
      offsetY: '=?'
      force: '=?'
      doc: '=?'
      minWidth: '=?'
      minHeight: '=?'
      maxWidth: '=?'
      maxHeight: '=?'
    link: ($scope, elem) ->

      elem.addClass 'aspect-Ratio'

      getWidth = ->
        console.log('parent_getWidth')
        console.log(elem.parent().width())
        width = elem.parent().width() - $scope.offsetX
        if width > $scope.maxWidth
          width = $scope.maxWidth
        else if width < $scope.minWidth
          width = $scope.minWidth
        console.log('resizeAspectRatio_getWidth')
        console.log(width)
        width

      getHeight = -> 
        console.log('parent_getHeight')
        console.log(elem.parent().parent().parent().height())
        console.log(elem.parent().height())
        height = elem.parent().parent().parent().height() - ($scope.offsetY)
        if height > $scope.maxHeight
          height = $scope.maxHeight
        else if height < $scope.minHeight
          height = $scope.minHeight
        console.log('resizeAspectRatio_getHeight')
        console.log(height)
        # if height > elem.parent().height()  then height = elem.parent().height()
        height

      resizeAspectRatio = -> 

        width = getWidth()
        height = getHeight()
        
        console.log('resizeAspectRatio')

        if width > $scope.maxWidth and height > $scope.maxHeight
          width = $scope.maxWidth
          height = $scope.maxHeight
        else if width < $scope.minWidth and height < $scope.minHeight
          width = $scope.minWidth
          height = $scope.minHeight
        else 
          width = Math.min(width / 1.7, height) * 1.7
          height = Math.min(width / 1.7, height)

        # console.log('getWidth')
        # console.log(width)
        # console.log('getHeight')
        # console.log(height)

        elem.css('min-Width': width)
        elem.css('Width': width)
        elem.css('min-height': height)
        elem.css('height': height)
        # elem.parent().children().get(1).css('height': height)
        elem.parent().children().get(1).style.height = height + "px"

      resizeTimeout = null

      $scope.$on 'window:resize', ->
        console.log('window:resize')
        resizeAspectRatio()
        if resizeTimeout
          $timeout.cancel(resizeTimeout)
        resizeTimeout = $timeout ->
          elem.css(overflow: '', width: '', 'min-width': '', height: '', 'min-height': '')
          resizeAspectRatio()
          resizeTimeout = null
        , 500
      console.log('aspectRatio: init')
      $timeout(resizeAspectRatio, 500)

]