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
        url: '/user/settings'
        templateUrl: 'app/views/user/settings.html'
        controller: 'UserSettingsCtrl'

      .state 'edit-protocol',
        url: '/edit-protocol/:id'
        templateUrl: 'app/views/skelton.html'
        controller: 'ProtocolCtrl'

      .state 'run-experiment',
        url: '/experiments/:id/run-experiment?chart'
        templateUrl: 'app/views/experiment/run-experiment.html'

      .state 'diagnostic-wizard',
        url: '/diagnostic-wizard/:id'
        templateUrl: 'app/views/diagnostic-wizard.html'



]
