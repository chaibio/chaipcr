# software update modal controller

window.App.controller 'SoftwareUpdateCtrl', [
  '$scope'
  '$uibModal'
  '$uibModalInstance'
  'Device'
  '$window'
  '$state'
  'Upload'
  '$timeout'
  '$interval'
  'Status'
  ($scope, $uibModal, $uibModalInstance, Device, $window, $state, Upload, $timeout, $interval, Status) ->

    uploadPromise = null
    $scope.loading = true
    $scope.content = 'update_available'

    Device.getUpdateInfo().then (data) ->
      if data
        data.version = data.version || data.software_version
        $scope.new_update = data
        $scope.loading = false

    $scope.doUpdate = ->
      $scope.content = 'update_in_progress'
      Device.updateSoftware()

    $scope.downloadUpdate = ->
      $window.open($scope.new_update.image_http_url)
      $scope.content = 'upload_form'

    $scope.imageSelected = (file) ->
      $scope.file = file

    $scope.cancelUpload = ->
      uploadPromise.abort() if uploadPromise
      uploadPromise = null
      $scope.uploading = false

    $scope.doUpload = ->
      return if !$scope.file
      errorCB = (err) ->
        $scope.upload_error = true
        $scope.uploading = false

      progressCB = (evt) ->
        $scope.percent_upload = parseInt(100.0 * evt.loaded / evt.total);

      successCB = ->
        $scope.content = 'update_in_progress'
        $timeout ->
          isUpInterval = $interval ->
            if Status.isUp()
              $scope.content = 'update_complete'
              $interval.cancel isUpInterval
          , 1000

        , 60 * 1000

      $scope.uploading = true
      $scope.percent_upload = 0;
      uploadPromise = Device.uploadImage($scope.file).then successCB, errorCB, progressCB


]
