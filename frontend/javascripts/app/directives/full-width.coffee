App.directive 'fullWidth', [
  'WindowWrapper'
  (WindowWrapper) ->

    restrict: 'AE',
    scope:
      useMin: '=?'
      useMax: '=?'
      offset: '=?'
    link: ($scope, elem) ->

      $scope.offset = ($scope.offset || 0) * 1

      set = ->
        width = WindowWrapper.width() - $scope.offset
        if $scope.useMin is true
          elem.css('min-width': width)
        if $scope.useMax is true
          elem.css('max-width': width)
        if !$scope.useMin && !$scope.useMax
          elem.css(width: width)

      set()

      $scope.$on 'window:resize', set

]