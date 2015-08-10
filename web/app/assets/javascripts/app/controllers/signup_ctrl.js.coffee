window.ChaiBioTech.ngApp.controller 'SignUpCtrl', [
  '$scope'
  'User'
  '$state'
  'Auth'
  ($scope, User, $state, Auth) ->
    $scope.user =
      role: 'admin'

    Auth.isLoggedIn()
    .then ->
      $state.go 'home'
    .catch (resp) ->
      if resp.data.errors is 'login in'
        $state.go 'login'

    $scope.submit = ->
      User.save($scope.user)
      .then ->
        Auth.login($scope.user.email, $scope.user.password)
        .then ->
          $state.go 'home'
        .catch ->
          $state.go 'login'

      .catch (resp) ->
        $scope.errors = resp.user.errors
]