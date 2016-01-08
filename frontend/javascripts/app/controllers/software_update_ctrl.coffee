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
    $scope.content = 'update_available'

    Device.getUpdateInfo().then (data) ->
      $scope.new_update = data

    $scope.doUpdate = ->
      $scope.content = 'update_in_progress'
      Device.updateSoftware()

    $scope.downloadUpdate = ->
      $state.go 'upload-image'
      $window.open("ftp://#{$scope.new_update.image_url}", '_blank')
      $uibModalInstance.dismiss()

]