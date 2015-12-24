window.App.controller 'UploadImageCtrl', [
  '$scope'
  'Upload'
  ($scope, Upload) ->

    successCB = (resp) ->
      $scope.uploading = false
      alert('Upload success!');

    errorCB = (resp) ->
      $scope.uploading = false
      alert('Error upload! Please check browser console for details.');

    progressCB = (evt) ->
      progressPercentage = parseInt(100.0 * evt.loaded / evt.total);
      $scope.percent_upload = progressPercentage

    $scope.upload = (file) ->
      $scope.uploading = true
      uploadPromise = Upload.upload
        url: '/device/upload_software_update'
        data:
          data: file

      uploadPromise.then successCB, errorCB, progressCB

]