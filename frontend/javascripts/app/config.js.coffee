###
Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
For more information visit http://www.chaibio.com

Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###
window.ChaiBioTech.ngApp
.run [
  '$rootScope'
  '$state'
  '$window'
  'Status'
  'PeriodicUpdate'
  'NetworkSettingsService'
  'IsTouchScreen'
  'WindowWrapper'
  ($rootScope, $state, $window, Status, PeriodicUpdate, NetworkSettingsService, IsTouchScreen, WindowWrapper) ->

    IsTouchScreen()
    WindowWrapper.initEventHandlers()

    $rootScope.title = "ChaiBioTech"

    Status.startSync()
    PeriodicUpdate.init()
    NetworkSettingsService.getReady();
    
    if not $.jStorage.get('userNetworkSettings')
      userNetworkSettings =
        wifiSwitchOn: true
      $.jStorage.set('userNetworkSettings', userNetworkSettings)

    $rootScope.$on '$stateChangeSuccess', (e, toState, params, fromState) ->
      if fromState.name isnt toState.name
        body = angular.element('body')
        body.addClass "#{toState.name}-state-active"
        body.removeClass "#{fromState.name}-state-active"

    $rootScope.$on 'event:auth-loginRequired', (e, rejection)->
      $window.document.cookie = 'authentication_token=; expires=Thu, 01 Jan 1970 00:00:01 GMT;';
      $.jStorage.deleteKey 'authToken'
      if !Status.isUpdating()
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
