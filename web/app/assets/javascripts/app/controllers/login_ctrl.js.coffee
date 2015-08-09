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


    return
]