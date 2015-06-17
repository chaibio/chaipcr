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
        templateUrl: 'angular/views/home.html'

]