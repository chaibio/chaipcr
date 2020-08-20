window.App.controller 'SettingsModalCtrl', [
  '$scope'
  'User'
  'Device'
  '$rootScope'
  '$timeout'
  ($scope, User, Device, $rootScope, $timeout) ->

    $scope.isBeta = true
    $scope.checked = false

    $scope.page = 'system-update'
    $scope.page_title = 'Manage User'
    $scope.update_available = 'unavailable'

    $scope.$on 'status:data:updated', (e, data, oldData) ->
      status = data?.device?.update_available || 'unknown'
      if status isnt 'unknown'
        $scope.update_available = status

      return if !data
      return if !data.experiment_controller
      $scope.state = data.experiment_controller.machine.state

    init = () ->
      Device.getVersion(true).then (resp) ->
        $scope.version_data = resp
        if resp.software_release_variant == "beta"
          $scope.isBeta = true

      User.getCurrent().then (resp) ->
        $scope.user = resp.data.user

      Device.isDualChannel()
      .then (resp) ->
        $scope.checked = true
        $scope.is_dual_channel = resp

      $scope.users = []
      User.fetch().then (users) ->
        $scope.users = users

    init()

    $scope.onPageClose = ->
      $scope.page = 'system-update';
      $scope.page_title = '';

    $scope.updateSoftware = ->
      Device.updateSoftware()

    $scope.openUpdateModal = ->
      Device.openUpdateModal()

    $scope.checkForUpdates = ->
      $scope.checking_update = true

      checkPromise = Device.checkForUpdate()
      checkPromise.then (is_available) ->
        $scope.update_available = is_available
        $scope.checkedUpdate = true
        if is_available is 'available'
          $scope.openUpdateModal()

      checkPromise.catch ->
        alert 'Error while checking update!'
        $scope.update_available = 'unavailable'
        $scope.checkedUpdate = false

      checkPromise.finally ->
        $scope.checking_update = false

    # Manage User page
    $scope.onChangePage = (page) ->
      $scope.page = page
      switch page
        when 'users'
          $scope.page_title = 'Manage User'
        when 'network'
          $scope.page_title = 'Network Connections'
        when 'maintenance'
          $scope.page_title = 'Maintenance'
        when 'system'
          $scope.page_title = 'System'

    $scope.onEditClick = () ->
      $scope.onChangePage('users')
      $timeout ->
        $rootScope.$broadcast 'modal:edit-user', { user: $scope.user }
      , 100

    $scope.$on 'modal:maintenance', (e, data, oldData) ->
      $scope.onChangePage('maintenance')

]
