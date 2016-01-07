# software update modal controller

window.App.controller 'SoftwareUpdateCtrl', [
  '$scope'
  '$uibModal'
  '$uibModalInstance'
  'Device'
  '$window'
  '$state'
  ($scope, $uibModal, $uibModalInstance, Device, $window, $state) ->

    updatePromise = null

    if $scope.data.version
      $scope.content = 'update_available'
      $scope.new_update = $scope.data

    if $scope.error
      $scope.content = 'unable_to_update'

    $scope.doUpdate = ->
      $scope.content = 'update_in_progress'

      updatePromise = Device.updateSoftware()

      updatePromise.then ->
        $scope.data.updating = 'complete'

      updatePromise.catch ->
        $scope.data.updating = 'failed'

    $scope.downloadUpdate = ->
      $state.go 'upload-image'
      $window.open("ftp://#{$scope.new_update.image_url}", '_blank')
      $uibModalInstance.dismiss()

]