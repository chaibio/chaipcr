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
        width = if $scope.minWidth then (if width > $scope.minWidth then width else $scope.minWidth) else width
        width = elem.parent().width() - $scope.offsetX
        width

      getHeight = -> 
        
        height = if $scope.doc
                  WindowWrapper.documentHeight() - $scope.offsetY
                else if $scope.parent
                  elem.parent().height() - $scope.offsetY
                else
                  WindowWrapper.height() - $scope.offsetY

        height = if $scope.minHeight > height then $scope.minHeight else height
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

      $timeout(resizeAspectRatio, 300)

]