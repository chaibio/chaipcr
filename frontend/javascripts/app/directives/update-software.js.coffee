window.App.directive 'updateSoftware', [
  'SoftwareUpdater'
  'Status'
  (SoftwareUpdater, Status) ->

    restrict: 'EA'
    link: ($scope, elem) ->

      $scope.$watch ->
        Status.getData()
      , (data) ->
        $scope.update_available = data?.device.update_available

      checkUpdateModal = null
      modalProgress = null

      elem.on 'click', (e) ->
        $scope.$apply ->
          $scope.checkForUpdate()

      $scope.updateSoftware = ->
        SoftwareUpdater.openSoftwareUpdateModal()

      $scope.checkForUpdate = ->
        SoftwareUpdater.checkForUpdate()
]