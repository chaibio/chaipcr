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
        width = elem.parent().width() - $scope.offsetX
        if width > $scope.maxWidth
          width = $scope.maxWidth
        else if width < $scope.minWidth
          width = $scope.minWidth
        width

      getHeight = -> 
        height = if $scope.doc
                  WindowWrapper.documentHeight() - $scope.offsetY
                else if $scope.parent
                  elem.parent().height() - $scope.offsetY
                else
                  WindowWrapper.height() - $scope.offsetY

        if height > $scope.maxHeight
          height = $scope.maxHeight
        else if height < $scope.minHeight
          height = $scope.minHeight

        if height > elem.parent().height()  then height = elem.parent().height()
        height

      resizeAspectRatio = -> 

        width = getWidth()
        height = getHeight()
        
        if width > $scope.maxWidth and height > $scope.maxHeight
          width = $scope.maxWidth
          height = $scope.maxHeight
        else if width < $scope.minWidth and height < $scope.minHeight
          width = $scope.minWidth
          height = $scope.minHeight
        else 
          width = Math.min(width / 1.7, height) * 1.7
          height = Math.min(width / 1.7, height)

        elem.css('min-Width': width)
        elem.css('Width': width)
        elem.css('min-height': height)
        elem.css('height': height)

          
      resizeTimeout = null

      $scope.$on 'window:resize', ->
        resizeAspectRatio()
        if resizeTimeout
          $timeout.cancel(resizeTimeout)

        resizeTimeout = $timeout ->
          # elem.css(overflow: '', width: '', 'min-width': '', height: '', 'min-height': '')
          resizeTimeout = null
        , 200

      $timeout(resizeAspectRatio, 1300)

]