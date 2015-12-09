window.App.directive 'versionInfo', [
  'Device'
  (Device) ->
    restrict: 'EA'
    replace: true
    scope:
      cache: '='
    templateUrl: 'app/views/directives/version-info.html'
    link: ($scope, elem, attrs) ->

      Device.getVersion($scope.cache).then (resp) ->
        console.log resp

]