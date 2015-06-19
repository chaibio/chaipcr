window.ChaiBioTech.ngApp

.controller 'LoginCtrl', [
  '$scope'
  '$state'
  ($scope, $state) ->

    @login = ->
      $state.go 'home'

    return
]