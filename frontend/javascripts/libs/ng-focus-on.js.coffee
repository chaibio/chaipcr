app = angular.module 'focusOn', []

app.directive 'focusOn', ->
  (scope, elem, attr) ->
    scope.$on 'focusOn', (e, name) ->
      elem[0].focus() if name is attr.focusOn

app.factory 'focus', ['$rootScope', '$timeout', (($rootScope, $timeout) ->
  (name) ->
    $timeout -> # wait until next tick so that all other deferred actions happen first
      $rootScope.$broadcast 'focusOn', name
)]
