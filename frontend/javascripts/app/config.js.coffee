window.ChaiBioTech.ngApp
.run [
  '$rootScope'
  '$state'
  '$window'
  ($rootScope, $state, $window) ->

    $rootScope.title = "ChaiBioTech"

    $rootScope.$on '$stateChangeSuccess', (e, toState, params, fromState) ->
      body = angular.element('body')
      body.addClass "#{toState.name}-state-active"
      body.removeClass "#{fromState.name}-state-active"

    $rootScope.$on 'event:auth-loginRequired', (e, rejection)->
      $.jStorage.deleteKey 'authToken'
      $window.location.assign '/'

]

.config [
  'laddaProvider'
  (laddaProvider) ->
    laddaProvider.setOption
      style: 'expand-right'
]

.value 'host', "http://#{window.location.hostname}"