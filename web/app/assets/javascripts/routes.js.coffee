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
        templateUrl: 'views/home.html'
        controller: 'HomeCtrl'

      .state 'settings',
        url: '/user/settings'
        templateUrl: 'views/user/settings.html'
        controller: 'UserSettingsCtrl'

]