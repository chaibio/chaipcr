window.App.controller 'SettingsCtrl', [
  '$scope'
  'User'
  'Device'
  ($scope, User, Device) ->

    $scope.isBeta = false

    User.getCurrent().then (resp) ->
      $scope.user = resp.data.user

    Device.getVersion().then (data) ->
      if data.software_release_variant == "beta"
        $scope.isBeta = true

    Device.getCapabilities()
    .then (resp) ->
      return if (!resp.data.capabilities)
      return if (!resp.data.capabilities.optics)
      return if (!resp.data.capabilities.optics.emission_channels)
      return if (!angular.isArray(resp.data.capabilities.optics.emission_channels))
      return if (resp.data.capabilities.optics.emission_channels.length isnt 2)
      $scope.is_dual_channel = true

    backdrop = $('.maintainance-backdrop')
    backdrop.css('height', $('.wizards-container').height())
]
