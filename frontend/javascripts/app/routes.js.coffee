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

.config [
  '$stateProvider'
  '$urlRouterProvider'
  ($stateProvider, $urlRouterProvider) ->

      $urlRouterProvider.otherwise("/home");

      $stateProvider

      .state 'signup',
        url: '/signup'
        templateUrl: 'app/views/signup.html'
        controller: 'SignUpCtrl'

      .state 'login',
        url: '/login'
        templateUrl: 'app/views/login.html'
        controller: 'LoginCtrl as LoginCtrl'

      .state 'home',
        url: '/home'
        templateUrl: 'app/views/home.html'
        controller: 'HomeCtrl as HomeCtrl'

      .state 'settings',
        abstruct: true
        url: '/settings'
        templateUrl: 'app/views/settings/root-menu.html'

      .state 'settings.root',
        url: '/'
        template: '<version-info></version-info>'

      .state 'settings.system',
        url: '/system'
        templateUrl: 'app/views/settings/system.html'

      .state 'settings.diagnostics',
        url: '/diagnostics'
        templateUrl: 'app/views/settings/diagnostics.html'

      .state 'settings.calibration',
        url: '/calibration'
        templateUrl: 'app/views/settings/calibration.html'

      .state 'settings.thermal_consistency',
        url: '/diagnostics/thermal_uniformity'
        template: '<div>'
        controller: ->
          window.location.assign('/dynexp/thermal_consistency/index.html')

      .state 'settings.usermanagement',
        url: '/usermanagement'
        templateUrl: 'app/views/settings/usermanagement.html'

      .state 'settings.usermanagement.new',
        url: '/new'
        templateUrl: 'app/views/settings/user-details.html'
        controller: 'newUserController'

      .state 'settings.current-user',
        url: '/current-user'
        templateUrl: 'app/views/settings/edit-current-user.html'
        controller: 'userDataController'

      .state 'settings.usermanagement.user',
        url: '/:id'
        templateUrl: 'app/views/settings/user-details.html'
        controller: 'userDataController'

      .state 'settings.networkmanagement',
        url: '/networkmanagement'
        templateUrl: 'app/views/settings/networkmanagement.html'

      .state 'settings.networkmanagement.wifi',
        url: '/:name'
        templateUrl: 'app/views/settings/network-details.html'

      .state 'edit-protocol',
        url: '/edit-protocol/:id'
        templateUrl: 'app/views/edit-protocol.html'

      .state 'samples-targets',
        url: '/samples-targets/:id'
        templateUrl: 'app/views/samples-targets.html'

      .state 'plate-layout',
        url: '/plate-layout/:id'
        templateUrl: 'app/views/plate-layout.html'

      .state 'run-experiment',
        url: '/experiments/:id/run-experiment?chart?max_cycle'
        templateUrl: 'app/views/experiment/run-experiment.html'

]
