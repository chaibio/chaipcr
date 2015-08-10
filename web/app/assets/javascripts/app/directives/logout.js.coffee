window.ChaiBioTech.ngApp.directive 'logout', [
  '$state'
  'Auth'
  '$rootScope'
  ($state, Auth, $rootScope) ->
    restrict: 'EA'
    link: ($scope, elem)->
      elem.click ->
        Auth.logout().then ->
          $state.go 'login'

]