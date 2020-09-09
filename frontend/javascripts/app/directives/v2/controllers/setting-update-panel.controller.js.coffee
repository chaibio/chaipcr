window.ChaiBioTech.ngApp.controller 'SettingUpdatePanelCtrl', [
  'Device'
  '$scope'
  'Status'
  '$http'
  '$window'
  '$timeout'
  (Device, $scope, Status, $http, $window, $timeout) ->
    $scope.update_available = 'unavailable'
    $scope.export_status = 'ready' # ready, progress, (done, failed)

    $scope.getVersionSoft = ->
      Device.getVersion(true).then ((resp) ->
        console.log resp
        $scope.data = resp
        return
      ), (noData) ->
        console.log noData
        # This is dummy data, to local checking. Will be removed.
        $scope.data =
          'serial_number': '1234789127894212'
          'model_number': 'M2342JA'
          'processor_architecture': 'armv7l'
          'software':
            'version': '1.0.0'
            'platform': 'S0100'
        return
      return

    $scope.$on 'status:data:updated', (e, data) ->
      status = if data and data.device then data.device.update_available else 'unknown'
      if status != 'unknown'
        $scope.update_available = status
      if data.device.update_available == 'unknown' and data.device.update_error
        if $scope.checkedUpdate
          #$scope.openUpdateModal();
        else
        #$scope.update_available = 'unavailable';
        #$scope.checkedUpdate = false;
        #$scope.openUpdateModal();
      return

    $scope.openUpdateModal = ->
      Device.openUpdateModal()
      return

    $scope.openUploadModal = ->
      Device.openUploadModal()
      return

    $scope.export = ->
      if $scope.export_status is 'progress' or $scope.export_status is 'done'
        return

      $scope.export_status = 'progress'
      isChrome = ! !window.chrome
      #alert(/Edge/.test(navigator.userAgent));
      console.log isChrome
      #debugger;
      if isChrome and !/Edge/.test(navigator.userAgent)
        Device.exportDatabase().then ((response) ->
          blob = new Blob([ response.data ], type: 'application/octet-stream')
          link = document.createElement('a')
          link.href = window.URL.createObjectURL(blob)
          link.download = 'exportdb.zip'
          link.click()
          $scope.export_status = 'done'
          return
        ), (response) ->
          $scope.export_status = 'failed'
          return
      else
        $scope.export_status = 'ready'
        $window.location.assign '/device/export_database'
      return

    $scope.checkUpdate = ->
      checkPromise = undefined
      $scope.checking_update = true
      checkPromise = Device.checkForUpdate()
      checkPromise.then (is_available) ->
        console.log is_available
        $scope.update_available = is_available
        $scope.checkedUpdate = true
        if is_available == 'available'
          $scope.openUpdateModal()
        return
      checkPromise['catch'] ->
        alert 'Error while checking update!'
        $scope.update_available = 'unavailable'
        $scope.checkedUpdate = false
        return
      checkPromise['finally'] ->
        $scope.checking_update = false
        return

    $scope.getVersionSoft()

    $scope.setReadyExportButton = () ->
      $scope.export_status = 'ready'

    return
]