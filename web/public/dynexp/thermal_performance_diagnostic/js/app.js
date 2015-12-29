(function () {
  'use strict';

  var App = window.App = angular.module('ThermalDiagnosticApp', [
    'ui.router',
    'ngResource',
    'http-auth-interceptor',
    'ui.bootstrap'
  ]);

  App.value('host', 'http://'+window.location.hostname);

  App.config([
    '$stateProvider',
    '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {

      $urlRouterProvider.otherwise('diagnostic-initialization');

      $stateProvider
      .state('diagnostic-initialization', {
        url: '/diagnostic-initialization',
        templateUrl: './views/init.html'
      })
      .state('diagnostic', {
        url: '/thermal-performance-diagnostic/:id',
        templateUrl: './views/diagnostic.html'
      });

    }
  ]);

})();