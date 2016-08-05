(function () {

  App.config([
    '$stateProvider',
    '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {

      $urlRouterProvider.otherwise('/intro');

      $stateProvider
      .state('intro', {
        url: '/intro',
        templateUrl: './views/intro.html'
      })
      .state('prepare-the-tubes', {
        url: '/prepare-the-tubes',
        templateUrl: './views/prepare-the-tubes.html'
      })
      .state('insert-water-strips', {
        url: '/insert-water-strips',
        templateUrl: './views/insert-water-strips.html'
      })
      .state('heating-and-reading-water', {
        url: '/heating-and-reading-water',
        templateUrl: './views/heating-and-reading-water.html'
      })
      .state('insert-fam-strips', {
        url: '/insert-fam-strips',
        templateUrl: './views/insert-fam-strips.html'
      })
      .state('reading-fam', {
        url: '/reading-fam',
        templateUrl: './views/reading-fam.html'
      })
      .state('insert-hex-strips', {
        url: '/insert-hex-strips',
        templateUrl: './views/insert-hex-strips.html'
      })
      .state('reading-hex', {
        url: '/reading-hex',
        templateUrl: './views/reading-hex.html'
      })
      .state('analyze', {
        url: '/analyze/:id',
        templateUrl: './views/analyze.html'
      });

    }
  ]);
})();