App.directive 'minHeight', [
  'WindowWrapper',
  (WindowWrapper) ->

    restrict: 'AE',
    scope:
      offset: '='
    link: ($scope, elem) ->

      elem.css
        minHeight: WindowWrapper.height() - $scope.offset

]