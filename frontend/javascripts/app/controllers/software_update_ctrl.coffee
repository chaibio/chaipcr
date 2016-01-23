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
  'Status',
  'host',
  ($scope, $uibModal, $uibModalInstance, Device, $window, $state, Upload, $timeout, $interval, Status, host) ->

    uploadPromise = null
    $scope.loading = true
    $scope.content = 'update_available'
    upFile = null
    $scope.file_name = ""

    if Device.direct_upload isnt true
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
      upFile = file
      $scope.uploading = false
      $scope.upload_error = false;
      $scope.file_name = file.name;
      $scope.file = true


    $scope.cancelUpload = ->
      uploadPromise.abort() if uploadPromise
      uploadPromise = null
      $scope.uploading = false

    $scope.doUpload = (file)->
      return if !upFile
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
      uploadPromise = Device.uploadImage(upFile).then successCB, errorCB, progressCB


]
