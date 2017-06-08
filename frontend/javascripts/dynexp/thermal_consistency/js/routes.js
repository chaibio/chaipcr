(function () {

  angular.module('dynexp.thermal_consistency').config([
    '$stateProvider',
    '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {

      $stateProvider
      .state('thermal_consistency', {
        abstract: true,
        url: '/dynexp/thermal-consistency',
        templateUrl: 'dynexp/thermal_consistency/index.html'
      })
      .state('thermal_consistency.introduction', {
        url: '/introduction',
        templateUrl: 'dynexp/thermal_consistency/views/intro.html'
      })
      .state('thermal_consistency.exp-running', {
        url: '/exp-running',
        templateUrl: 'dynexp/thermal_consistency/views/exp-running.html'
      })
      .state('thermal_consistency.analyze', {
        url: '/analyze/:id',
        templateUrl: 'dynexp/thermal_consistency/views/analyze.html'
      });

    }
  ]);
})();