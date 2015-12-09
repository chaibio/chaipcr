window.App.directive 'versionInfo', [
  'Device'
  (Device) ->
    restrict: 'EA'
    replace: true
    templateUrl: 'app/views/directives/version-info.html'
    link: ($scope, elem, attrs) ->
      Device.getVersion().then (resp) ->
        console.log resp

]