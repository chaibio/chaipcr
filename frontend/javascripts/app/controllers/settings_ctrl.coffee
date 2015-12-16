window.App.controller 'SettingsCtrl', [
  '$scope'
  'User'
  ($scope, User) ->
    User.getCurrent().then (resp) ->
      $scope.user = resp.data.user

    backdrop = $('.maintainance-backdrop')
    backdrop.css('height', $('.wizards-container').height())
]