window.ChaiBioTech.ngApp
.run [
  '$rootScope'
  ($rootScope) ->
    $rootScope.title = "ChaiBioTech"
    $rootScope.$on '$stateChangeSuccess', (e, toState) ->
      if toState.name is 'login'
        angular.element('body').addClass('login-page-active')
      else
        angular.element('body').removeClass('login-page-active')

]

.value 'host', "http://#{window.location.hostname}"