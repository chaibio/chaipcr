window.App.service 'SoftwareUpdater', [
  'Status'
  'Device'
  '$rootScope'
  '$modal'
  '$window'
  (Status, Device, $rootScope, $modal, $window) ->

    checkUpdateModal = null
    modalProgress = null

    @updateInProgressModal = ->
      return if modalProgress
      modalProgress = $modal.open
        templateUrl: 'app/views/directives/update-software/modal-update-in-progress.html'

      updatePromise = Device.updateSoftware()

      updatePromise.then (resp) ->
        $window.location.reload()

      updatePromise.catch (err) ->
        $modal.open
          templateUrl: 'app/views/directives/update-software/modal-update-error.html'

      updatePromise.finally ->
        modalProgress.dismiss()
        modalProgress = null


    @checkForUpdate = ->
      Device.checkForUpdate().then (resp) =>
        $scope = $rootScope.$new()
        $scope.update = resp.data
        $scope.updateSoftware = @updateInProgressModal

        # $scope.update = {'upgrade':{'version':'1.0.1','release_date':null,'brief_description':'this is the brief description','full_description':'this is the full description'}}

        if resp.data.upgrade
          checkUpdateModal = $modal.open
            templateUrl: 'app/views/directives/update-software/modal-update-available.html'
            scope: $scope
            openedClass: 'modal-software-update-open'
        else
          $modal.open
            templateUrl: 'app/views/directives/update-software/modal-no-updates.html'

    @init = ->
      Status.startSync()
      $rootScope.$watch ->
        Status.getData()
      , (data) =>
        if data?.device.update_available is 'available' and !checkUpdateModal
          @checkForUpdate()

    return

]