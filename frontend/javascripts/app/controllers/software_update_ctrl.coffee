###
Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
For more information visit http://www.chaibio.com

Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###
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
    _file = null

    if Device.direct_upload isnt true
      $scope.content = 'update_available'
      $scope.loading = true
      Device.getUpdateInfo().then (data) ->
        Status.fetch().then (resp) ->
          status = resp?.device?.update_available || 'unknown'
          # status = 'unknown'
          if status is 'available'
            delete data.image_http_url #remove image url so it wont display "download image" modal
          if data
            data.version = data.version || data.software_version
            $scope.new_update = data
            $scope.loading = false
    else
      $scope.content = 'upload_form'

    $scope.doUpdate = ->
      $scope.content = 'update_in_progress'
      Device.updateSoftware()

    $scope.downloadUpdate = ->
      $window.open($scope.new_update.image_http_url)
      $scope.content = 'upload_form'

    $scope.close = ->
      if $scope.uploading
        $scope.cancelUpload()
      $uibModalInstance.close()

    $scope.imageSelected = (file) ->
      return if !file
      _file = file
      $scope.upload_error = false
      _filename = file.name
      name_length = 30
      if file.name.length > name_length
        ext_index = _filename.lastIndexOf('.')
        ext = _filename.substring(ext_index, _filename.length)
        _filename = _filename.substring(0, name_length-ext.length-2)+'..'+ext
      $scope.file =
        name: _filename

    $scope.doUpload = ->
      return if !$scope.file
      return if $scope.uploading
      errorCB = (err) ->
        $scope.upload_error = err?.status?.error || 'An error occured while uploading software image. Please try again.'
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
