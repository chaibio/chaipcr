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
      .state('exp-running', {
        url: '/exp-running',
        templateUrl: './views/exp-running.html'
      })
      .state('analyze', {
        url: '/analyze/:id',
        templateUrl: './views/analyze.html'
      });

    }
  ]);
})();