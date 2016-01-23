window.App.directive 'versionInfo', [
  'Device'
  'Status'
  '$rootScope'
  (Device, Status, $rootScope) ->
    restrict: 'EA'
    replace: true
    scope:
      cache: '='
    templateUrl: 'app/views/directives/version-info.html'
    link: ($scope, elem, attrs) ->

      $scope.update_available = 'unavailable'

      $scope.$on 'status:data:updated', (e, data) ->
        status = data?.device?.update_available || 'unknown'
        if status isnt 'unknown'
          $scope.update_available = status

      Device.getVersion(true).then (resp) ->
        $scope.data = resp

      $scope.updateSoftware = ->
        Device.updateSoftware()

      $scope.openUpdateModal = ->
        Device.openUpdateModal()

      $scope.checkForUpdates = ->
        $scope.checking_update = true

        checkPromise = Device.checkForUpdate()
        checkPromise.then (is_available) ->
          $scope.update_available = is_available
          $scope.checkedUpdate = true
          if is_available is 'available'
            $scope.openUpdateModal()

        checkPromise.catch ->
          alert 'Error while checking update!'
          $scope.update_available = 'unavailable'
          $scope.checkedUpdate = false

        checkPromise.finally ->
          $scope.checking_update = false

]
