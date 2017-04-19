angular.module('dynexp.optical_test_dual_channel').config([
  '$stateProvider',
  '$urlRouterProvider',
  function($stateProvider, $urlRouterProvider) {

    $stateProvider
      .state('optical_test_2ch', {
        abstract: true,
        url: '/dynexp/optical-test-dual-channel',
        templateUrl: 'dynexp/optical_test_dual_channel/index.html'
      })
      .state('optical_test_2ch.intro', {
        url: '/introduction',
        templateUrl: 'dynexp/optical_test_dual_channel/views/page-1.html'
      })
      .state('optical_test_2ch.page-2', {
        url: '/step-1',
        templateUrl: 'dynexp/optical_test_dual_channel/views/page-2.html'
      })
      .state('optical_test_2ch.page-3', {
        url: '/step-2',
        templateUrl: 'dynexp/optical_test_dual_channel/views/page-3.html'
      })
      .state('optical_test_2ch.page-4', {
        url: '/step-3',
        templateUrl: 'dynexp/optical_test_dual_channel/views/page-4.html'
      })
      .state('optical_test_2ch.page-5', {
        url: '/step-4',
        templateUrl: 'dynexp/optical_test_dual_channel/views/page-5.html'
      })
      .state('optical_test_2ch.page-6', {
        url: '/step-5',
        templateUrl: 'dynexp/optical_test_dual_channel/views/page-6.html'
      })
      .state('optical_test_2ch.page-7', {
        url: '/step-6',
        templateUrl: 'dynexp/optical_test_dual_channel/views/page-7.html'
      })
      .state('optical_test_2ch.page-8', {
        url: '/step-7',
        templateUrl: 'dynexp/optical_test_dual_channel/views/page-8.html'
      })
      .state('optical_test_2ch.page-9', {
        url: '/analyze/:id',
        templateUrl: 'dynexp/optical_test_dual_channel/views/page-9.html'
      });

  }
]);
