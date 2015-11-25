(function () {

  App.config([
    '$stateProvider',
    '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {

      $urlRouterProvider.otherwise('introduction');

      $stateProvider
      .state('introduction', {
        url: '/introduction',
        templateUrl: './views/intro.html'
      })
      .state('step-1', {
        url: '/step-1',
        templateUrl: './views/step-1.html'
      })
      .state('step-2', {
        url: '/step-2',
        templateUrl: './views/step-2.html'
      })
      .state('step-3', {
        url: '/step-3',
        templateUrl: './views/step-3.html'
      })
      .state('step-4', {
        url: '/step-4',
        templateUrl: './views/step-4.html'
      })
      .state('step-5', {
        url: '/step-5',
        templateUrl: './views/step-5.html'
      })
      .state('step-6', {
        url: '/step-6',
        templateUrl: './views/step-6.html'
      })
      .state('step-7', {
        url: '/step-7',
        templateUrl: './views/step-7.html'
      });

    }
  ]);
})();