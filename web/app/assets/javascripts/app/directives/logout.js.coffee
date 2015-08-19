window.ChaiBioTech.ngApp.directive 'logout', [
  '$state'
  'Auth'
  '$rootScope'
  '$window'
  ($state, Auth, $rootScope, $window) ->
    restrict: 'EA'
    link: ($scope, elem)->
      elem.click ->
        Auth.logout().then ->
          $window.location.assign '/'


]