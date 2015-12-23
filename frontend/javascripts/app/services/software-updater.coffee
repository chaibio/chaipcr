window.App.service 'SoftwareUpdater', [
  'Status'
  'Device'
  '$rootScope'
  '$modal'
  '$window'
  (Status, Device, $rootScope, $modal, $window) ->

    @checkForUpdate = ->
      checkUpdateModal = $modal.open
        templateUrl: 'app/views/directives/update-software/modal-software-update.html'
        controller: 'SoftwareUpdateCtrl'
        openedClass: 'modal-software-update-open'

    # @init = ->
    #   Status.startSync()
    #   $rootScope.$watch ->
    #     Status.getData()
    #   , (data) =>
    #     if data?.device.update_available is 'available' and !checkUpdateModal
    #       @checkForUpdate()

    return

]