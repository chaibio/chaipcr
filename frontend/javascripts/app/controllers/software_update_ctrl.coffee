# software update modal controller

window.App.controller 'SoftwareUpdateCtrl', [
  '$scope'
  '$uibModal'
  '$uibModalInstance'
  'Device'
  '$window'
  '$state'
  ($scope, $uibModal, $uibModalInstance, Device, $window, $state) ->

    # $scope.update = {'upgrade':{'version':'1.0.1','release_date':null,'brief_description':'this is the brief description','full_description':'this is the full description'}}
    $scope.content = 'checking_for_updates'
    updatePromise = null

    checkForUpdatePromise = Device.checkForUpdate()
    checkForUpdatePromise.then (data) ->
      if data.version
        $scope.content = 'update_available'
        $scope.new_update = data
      else
        $scope.content = 'update_unavailable'

    checkForUpdatePromise.catch ->
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