App.directive 'fullHeight', [
  'WindowWrapper'
  '$timeout'
  (WindowWrapper, $timeout) ->

    restrict: 'AE',
    scope:
      offset: '=?'
      force: '=?'
      doc: '=?'
      parent: '=?'
    link: ($scope, elem) ->

      $scope.offset = $scope.offset || 0
      $scope.offset = $scope.offset * 1
      elem.addClass 'full-height'

      getHeight = ->
        if $scope.doc
          WindowWrapper.documentHeight() - $scope.offset
        else if $scope.parent
          elem.parent().height() - $scope.offset
        else
          WindowWrapper.height() - $scope.offset

      set = ->

        height = getHeight()
        if ($scope.force)
          elem.css( 'height':  height )
        else
          # height = if elem.height() > height then elem.height() else height
          elem.css( 'min-height' : height )

      resizeTimeout = null

      $scope.$on 'window:resize', ->
        height = getHeight()
        elem.css('min-height': height, height: '', overflow: 'hidden')
        if resizeTimeout
          $timeout.cancel(resizeTimeout)

        resizeTimeout = $timeout ->
          elem.css(overflow: '', height: '', 'min-height': '')
          set()
          resizeTimeout = null
        , 600

      $timeout(set, 100)

]