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
      .state('step-2', {
        url: '/step-2',
        templateUrl: './views/page-2.html'
      });

    }
  ]);
})();