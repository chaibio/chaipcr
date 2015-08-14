window.ChaiBioTech.ngApp

.controller 'LoginCtrl', [
  '$scope'
  '$state'
  'Auth'
  ($scope, $state, Auth) ->

    $scope.user = {}

    @login = ->
      Auth.login($scope.user.email, $scope.user.password)
      .then ->
        $state.go 'home'

      .catch (resp) ->
        if resp.data.errors is 'sign up'
          return $state.go 'signup'

        $scope.user = {}
        $scope.error = resp.data.errors

    return
]