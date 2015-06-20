window.ChaiBioTech.ngApp

.config [
  '$stateProvider'
  '$urlRouterProvider'
  '$locationProvider'
  ($stateProvider, $urlRouterProvider) ->

      $urlRouterProvider.otherwise("/login");

      $stateProvider

      .state 'login',
        url: '/login'
        templateUrl: 'app/views/login.html'
        controller: 'LoginCtrl as LoginCtrl'

      .state 'home',
        url: '/home'
        templateUrl: 'app/views/home.html'
        controller: 'HomeCtrl as HomeCtrl'

      .state 'settings',
        url: '/user/settings'
        templateUrl: 'app/views/user/settings.html'
        controller: 'UserSettingsCtrl'

      .state 'expTemperatureLog',
        url: '/experiments/:expId/temperature-log?starttime&endtime&resolution'
        templateUrl: 'app/views/experiment/temperature-log.html'
        controller: 'ExperimentTemperatureLogCtrl as TemperatureCtrl'

      .state 'edit-protocol',
        url: '/edit-protocol/:id'
        templateUrl: 'app/views/skelton.html'
        controller: 'ProtocolCtrl'


]
