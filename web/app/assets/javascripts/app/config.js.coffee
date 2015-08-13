window.ChaiBioTech.ngApp
.run [
  '$rootScope'
  '$state'
  '$window'
  ($rootScope, $state, $window) ->
    $rootScope.title = "ChaiBioTech"


    $rootScope.$on '$stateChangeSuccess', (e, toState, params, fromState) ->
      angular.element('body').addClass "#{toState.name}-state-active"
      angular.element('body').removeClass "#{fromState.name}-state-active"

    $rootScope.$on 'event:auth-loginRequired', (e, rejection)->
      $window.authToken = null

      if (rejection.data.errors is 'sign up')
        $state.go 'signup'

      else
        $state.go 'login'

    $rootScope.$on '$stateChangeStart', (e, toState, params, fromState) ->
      if (toState.name is 'login') and $window.authToken
        e.preventDefault()
        $state.go fromState.name

]

.value 'host', "http://#{window.location.hostname}"