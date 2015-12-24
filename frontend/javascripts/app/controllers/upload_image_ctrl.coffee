window.App.controller 'UploadImageCtrl', [
  '$scope'
  'Device'
  ($scope, Device) ->

    successCB = (resp) ->
      $scope.uploading = false
      alert('Upload success!');

    errorCB = (resp) ->
      $scope.uploading = false
      alert('Error upload! Please check browser console for details.');
      console.log resp

    progressCB = (evt) ->
      progressPercentage = parseInt(100.0 * evt.loaded / evt.total);
      $scope.percent_upload = progressPercentage

    $scope.upload = (file) ->
      $scope.uploading = true
      Device.uploadImage(file).then successCB, errorCB, progressCB

]