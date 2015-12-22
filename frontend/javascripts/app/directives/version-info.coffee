window.App.directive 'versionInfo', [
  'Device'
  'Status'
  'SoftwareUpdater'
  (Device, Status, SoftwareUpdater) ->
    restrict: 'EA'
    replace: true
    scope:
      cache: '='
    templateUrl: 'app/views/directives/version-info.html'
    link: ($scope, elem, attrs) ->

      $scope.$watch ->
        Status.getData()
      , (data) ->
        $scope.update_available = data?.device?.update_available

      Device.getVersion(true).then (resp) ->
        $scope.data = resp

      $scope.updateSoftware = ->
        Device.updateSoftware()

      $scope.checkForUpdates = ->
        $scope.checkedUpdate = true
        SoftwareUpdater.checkForUpdate()


]