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
    _file = null

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
      return if !file
      _file = file
      $scope.upload_error = false
      $scope.file =
        name: file.name.substring(0, 24)+'...'

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
      uploadPromise = Device.uploadImage(_file)
      .success(successCB)
      .error( errorCB)
      .progress( progressCB)
      .xhr (xhr) ->
        $scope.cancelUpload = ->
          xhr.abort()
          uploadPromise = null
          _file = null
          $scope.file = null
          $scope.uploading = false


]
