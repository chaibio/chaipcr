(function () {
  'use strict';

  angular.module('dynexp.thermal_performance_diagnostic', [
    'ui.router',
    'ngResource',
    'http-auth-interceptor',
    'ui.bootstrap',
    'dynexp.libs',
  ])
  .config([
    '$stateProvider',
    '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {

      $stateProvider
      .state('thermal_performance_diagnostic', {
        abstruct: true,
        url: '/dynexp/thermal-performance-diagnostic',
        templateUrl: 'dynexp/thermal_performance_diagnostic/index.html'
      })
      .state('thermal_performance_diagnostic.init', {
        url: '/diagnostic-initialization',
        templateUrl: 'dynexp/thermal_performance_diagnostic/views/init.html'
      })
      .state('thermal_performance_diagnostic.diagnostic', {
        url: '/thermal-performance-diagnostic/:id',
        templateUrl: 'dynexp/thermal_performance_diagnostic/views/diagnostic.html'
      });

    }
  ]);

})();
