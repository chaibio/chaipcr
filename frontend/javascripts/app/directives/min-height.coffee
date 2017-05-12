App.directive 'minHeight', [
  'WindowWrapper',
  (WindowWrapper) ->

    restrict: 'AE',
    scope:
      offset: '='
      force: '='
    link: ($scope, elem) ->

      set = ->
        $scope.offset = $scope.offset || 0
        if ($scope.force)
          elem.css( 'height': WindowWrapper.height() - $scope.offset )
        else
          elem.css( 'min-height' : WindowWrapper.height() - $scope.offset )

      $scope.$on 'window:resize', set

      set()

]