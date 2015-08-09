window.ChaiBioTech.ngApp.directive 'logout', [
  '$state'
  'Auth'
  ($state, Auth) ->
    restrict: 'EA'
    link: ->
      Auth.logout().then ->
        $state.go 'login'
]