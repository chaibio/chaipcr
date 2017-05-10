App.directive 'minHeight', [
  'WindowWrapper',
  (WindowWrapper) ->

    restrict: 'AE',
    scope:
      offset: '='
    link: ($scope, elem) ->

      elem.css
        minHeight: WindowWrapper.height() - $scope.offset

      $scope.$on 'window:resize', ->
        elem.css
          minHeight: WindowWrapper.height() - $scope.offset

]