window.App.controller 'SettingsCtrl', [
  '$scope'
  'User'
  'Device'
  ($scope, User, Device) ->

    $scope.isBeta = false;

    User.getCurrent().then (resp) ->
      $scope.user = resp.data.user

    Device.getVersion().then (data) ->
      if data.software_release_variant == "beta"
        $scope.isBeta = true

    backdrop = $('.maintainance-backdrop')
    backdrop.css('height', $('.wizards-container').height())
]
