window.ChaiBioTech.ngApp
.run [
  '$rootScope'
  '$state'
  'Auth'
  ($rootScope, $state, Auth) ->
    $rootScope.title = "ChaiBioTech"
    $rootScope.$on '$stateChangeSuccess', (e, toState) ->
      if toState.name is 'login'
        angular.element('body').addClass('login-page-active')
      else
        angular.element('body').removeClass('login-page-active')

    $rootScope.$on 'event:auth-loginRequired', (e, rejection)->
      Auth.authToken = null

      if (rejection.data.errors is 'sign up')
        $state.go 'signup'

      else if (rejection.data.errors is 'log in')
        $state.go 'login'

]

.value 'host', "http://#{window.location.hostname}"