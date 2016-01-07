window.App.directive 'versionInfo', [
  'Device'
  'Status'
  '$rootScope'
  '$uibModal'
  (Device, Status, $rootScope, $uibModal) ->
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
        $scope.checking_update = true
        scope = $rootScope.$new()
        scope.data = {}

        modalConfig =
          templateUrl: 'app/views/directives/update-software/modal-software-update.html'
          controller: 'SoftwareUpdateCtrl'
          scope: scope
          openedClass: 'modal-software-update-open'
          keyboard: false
          backdrop: 'static'

        checkPromise = Device.checkForUpdate()
        checkPromise.then (data) ->
          if data.version
            scope.data = data
            $uibModal.open modalConfig

        checkPromise.catch ->
          scope.error = true
          $uibModal.open modalConfig

        checkPromise.finally ->
          $scope.checking_update = false
          $scope.checkedUpdate = true



]