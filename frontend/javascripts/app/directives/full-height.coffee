App.directive 'fullHeight', [
  'WindowWrapper'
  '$timeout'
  (WindowWrapper, $timeout) ->

    restrict: 'AE',
    scope:
      offset: '=?'
      force: '=?'
      doc: '=?'
    link: ($scope, elem) ->

      set = ->
        $scope.offset = $scope.offset || 0
        height = (if $scope.doc then WindowWrapper.documentHeight() else  WindowWrapper.height()) - ($scope.offset * 1)
        if ($scope.force)
          elem.css( 'height':  height )
        else
          elem.css( 'min-height' : height )

      $scope.$on 'window:resize', ->
        elem.removeAttr('style')
        $timeout(set, 100)

      set()

]