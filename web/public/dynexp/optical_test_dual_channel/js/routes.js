(function () {

  App.config([
    '$stateProvider',
    '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {

      $urlRouterProvider.otherwise('/introduction');

      $stateProvider
      .state('page-1', {
        url: '/introduction',
        templateUrl: './views/page-1.html'
      })
      .state('page-2', {
        url: '/step-1',
        templateUrl: './views/page-2.html'
      })
      .state('page-3', {
        url: '/step-2',
        templateUrl: './views/page-3.html'
      })
      .state('page-4', {
        url: '/step-3',
        templateUrl: './views/page-4.html'
      })
      .state('page-5', {
        url: '/step-4',
        templateUrl: './views/page-5.html'
      })
      .state('page-6', {
        url: '/step-5',
        templateUrl: './views/page-6.html'
      })
      .state('page-7', {
        url: '/step-6',
        templateUrl: './views/page-7.html'
      })
      .state('page-8', {
        url: '/step-7',
        templateUrl: './views/page-8.html'
      })
      .state('page-9', {
        url: '/analyze',
        templateUrl: './views/page-9.html'
      });

    }
  ]);
})();