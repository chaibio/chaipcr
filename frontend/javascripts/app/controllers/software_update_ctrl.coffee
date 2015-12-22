# software update modal controller

window.App.controller 'SoftwareUpdateCtrl', [
  '$scope'
  '$modal'
  '$modalInstance'
  'Device'
  ($scope, $modal, $modalInstance, Device) ->

    # $scope.update = {'upgrade':{'version':'1.0.1','release_date':null,'brief_description':'this is the brief description','full_description':'this is the full description'}}
    $scope.content = 'checking_for_updates'
    updatePromise = null

    checkForUpdatePromise = Device.checkForUpdate()

    checkForUpdatePromise.then (resp) ->
      $scope.content = 'update_available'
      $scope.update_available = resp.data

    checkForUpdatePromise.catch ->
      cloudCheckPromise = Device.checkCloudUpdate()
      cloudCheckPromise.then (resp) ->
        cloudInfo = resp.data
        Device.getVersion().then (device) ->
          if cloudInfo.software_version isnt device.software.version
            $scope.content = 'update_available'
            $scope.update_available =
              upgrade:
                brief_description: cloudInfo.brief_description
                full_description: cloudInfo.full_description
                release_date: cloudInfo.release_date
                version: cloudInfo.software_version

          else
            $scope.content = 'update_unavailable'

      cloudCheckPromise.catch ->
        window.alert('Unable to check for updates!');

    $scope.doUpdate = ->
      $scope.content = 'update_in_progress'

      updatePromise = Device.updateSoftware()

      updatePromise.then ->
        $scope.data.updating = 'complete'

      updatePromise.catch ->
        $scope.data.updating = 'failed'

]