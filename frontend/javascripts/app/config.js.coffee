window.ChaiBioTech.ngApp
.run [
  '$rootScope'
  '$state'
  '$window'
  'Status'
  'PeriodicUpdate'
  'NetworkSettingsService'
  ($rootScope, $state, $window, Status, PeriodicUpdate, NetworkSettingsService) ->

    $rootScope.title = "ChaiBioTech"

    Status.startSync()
    PeriodicUpdate.init()
    NetworkSettingsService.getSettings();

    $rootScope.$on '$stateChangeSuccess', (e, toState, params, fromState) ->
      if fromState.name isnt toState.name
        body = angular.element('body')
        body.addClass "#{toState.name}-state-active"
        body.removeClass "#{fromState.name}-state-active"

    $rootScope.$on 'event:auth-loginRequired', (e, rejection)->
      $window.document.cookie = 'authentication_token=; expires=Thu, 01 Jan 1970 00:00:01 GMT;';
      $.jStorage.deleteKey 'authToken'
      $window.location.assign '/'

]

.config [
  'laddaProvider'
  'WebworkerProvider'
  (laddaProvider, WebworkerProvider) ->
    laddaProvider.setOption
      style: 'expand-right'

    WebworkerProvider.setHelperPath("/worker_wrapper.js")
    WebworkerProvider.setUseHelper(false)
    WebworkerProvider.setTransferOwnership(true)
]

.value 'host', "http://#{window.location.hostname}"
