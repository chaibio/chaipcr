(function () {

  App.config([
    '$stateProvider',
    '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {

      $stateProvider
      .state('optical_cal', {
        abstract: true,
        url: '/dynexp/optical-cal',
        templateUrl: 'dynexp/optical_cal/index.html'
      })
      .state('optical_cal.intro', {
        url: '/introduction',
        templateUrl: 'dynexp/optical_cal/views/intro.html'
      })
      .state('optical_cal.step-1', {
        url: '/step-1',
        templateUrl: 'dynexp/optical_cal/views/step-1.html'
      })
      .state('optical_cal.step-2', {
        url: '/step-2',
        templateUrl: 'dynexp/optical_cal/views/step-2.html'
      })
      .state('optical_cal.step-3', {
        url: '/step-3',
        templateUrl: 'dynexp/optical_cal/views/step-3.html'
      })
      .state('optical_cal.step-3-reading', {
        url: '/step-3-reading-data',
        templateUrl: 'dynexp/optical_cal/views/step-3-reading.html'
      })
      .state('optical_cal.step-4', {
        url: '/step-4',
        templateUrl: 'dynexp/optical_cal/views/step-4.html'
      })
      .state('optical_cal.step-5', {
        url: '/step-5',
        templateUrl: 'dynexp/optical_cal/views/step-5.html'
      })
      .state('optical_cal.step-6', {
        url: '/step-6',
        templateUrl: 'dynexp/optical_cal/views/step-6.html'
      });

    }
  ]);
})();