angular.module('dynexp.optical_test_single_channel')
  .config([
    '$stateProvider',
    '$urlRouterProvider',
    function($stateProvider, $urlRouterProvider) {

      $urlRouterProvider.otherwise('introduction');

      $stateProvider
        .state('optical_test_1ch', {
          abstract: true,
          url: '/dynexp/optical-test-single-channel',
          templateUrl: 'dynexp/optical_test_single_channel/index.html'
        })
        .state('optical_test_1ch.introduction', {
          url: '/introduction',
          templateUrl: 'dynexp/optical_test_single_channel/views/intro.html'
        })
        .state('optical_test_1ch.exp-running', {
          url: '/exp-running',
          templateUrl: 'dynexp/optical_test_single_channel/views/exp-running.html'
        })
        .state('optical_test_1ch.analyze', {
          url: '/analyze/:id',
          templateUrl: 'dynexp/optical_test_single_channel/views/analyze.html'
        });

    }
  ]);
