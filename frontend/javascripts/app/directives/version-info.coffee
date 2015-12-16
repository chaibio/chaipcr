window.App.directive 'versionInfo', [
  'Device'
  (Device) ->
    restrict: 'EA'
    replace: true
    scope:
      cache: '='
    templateUrl: 'app/views/directives/version-info.html'
    link: ($scope, elem, attrs) ->

      Device.getVersion(true).then (resp) ->
        $scope.data = resp

      $scope.checkForUpdate = ->
        Device.checkForUpdate().then (resp) ->
          $scope.update = resp

]