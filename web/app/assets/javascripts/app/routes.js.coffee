window.ChaiBioTech.ngApp

.config [
  '$stateProvider'
  '$urlRouterProvider'
  '$locationProvider'
  ($stateProvider, $urlRouterProvider) ->

      $urlRouterProvider.otherwise("/home");

      $stateProvider

      .state 'home',
        url: '/home'
        templateUrl: 'app/views/home.html'
        controller: 'HomeCtrl as HomeCtrl'

      .state 'settings',
        url: '/user/settings'
        templateUrl: 'app/views/user/settings.html'
        controller: 'UserSettingsCtrl'

]