App.directive 'fullWidth', [
  'WindowWrapper'
  (WindowWrapper) ->

    restrict: 'AE',
    scope:
      force: '='
    link: ($scope, elem) ->
      set = ->
        if $scope.force
          elem.css(width: WindowWrapper.width())
        else
          elem.css('min-width': WindowWrapper.width())

      set()

      $scope.$on 'window:resize', set

]