window.ChaiBioTech.ngApp
.run [
  '$rootScope'
  '$state'
  ($rootScope, $state) ->
    $rootScope.title = "ChaiBioTech"


    $rootScope.$on '$stateChangeSuccess', (e, toState, params, fromState) ->
      angular.element('body').addClass "#{toState.name}-state-active"
      angular.element('body').removeClass "#{fromState.name}-state-active"

    $rootScope.$on 'event:auth-loginRequired', (e, rejection)->
      $.jStorage.deleteKey 'authToken'

      if (rejection.data.errors is 'sign up')
        $state.go 'signup'

      else
        $state.go 'login'

    $rootScope.$on '$stateChangeStart', (e, toState, params, fromState) ->
      if (toState.name is 'login') and $.jStorage.get('authToken', null)
        e.preventDefault()
        $state.go fromState.name

]

.value 'host', "http://#{window.location.hostname}"