angular.module('dynexp.dual_channel_optical_cal_v2')

.config([
    '$stateProvider',
    '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {

      $stateProvider
      .state('2_channel_optical_cal', {
        url: '/dynexp/dual-channel-optical-cal',
        templateUrl: 'dynexp/dual_channel_optical_cal_v2/views/index.html'
      })
      .state('2_channel_optical_cal.intro', {
        url: '/intro',
        templateUrl: 'dynexp/dual_channel_optical_cal_v2/views/intro.html'
      })
      .state('2_channel_optical_cal.prepare-the-tubes', {
        url: '/prepare-the-tubes',
        templateUrl: 'dynexp/dual_channel_optical_cal_v2/views/prepare-the-tubes.html'
      })
      .state('2_channel_optical_cal.insert_water_strips', {
        url: '/insert-water-strips',
        templateUrl: 'dynexp/dual_channel_optical_cal_v2/views/insert-water-strips.html'
      })
      .state('2_channel_optical_cal.heating-and-reading-water', {
        url: '/heating-and-reading-water',
        templateUrl: 'dynexp/dual_channel_optical_cal_v2/views/heating-and-reading-water.html'
      })
      .state('2_channel_optical_cal.insert-fam-strips', {
        url: '/insert-fam-strips',
        templateUrl: 'dynexp/dual_channel_optical_cal_v2/views/insert-fam-strips.html'
      })
      .state('2_channel_optical_cal.reading-fam', {
        url: '/reading-fam',
        templateUrl: 'dynexp/dual_channel_optical_cal_v2/views/reading-fam.html'
      })
      .state('2_channel_optical_cal.insert-hex-strips', {
        url: '/insert-hex-strips',
        templateUrl: 'dynexp/dual_channel_optical_cal_v2/views/insert-hex-strips.html'
      })
      .state('2_channel_optical_cal.reading-hex', {
        url: '/reading-hex',
        templateUrl: 'dynexp/dual_channel_optical_cal_v2/views/reading-hex.html'
      })
      .state('2_channel_optical_cal.analyze', {
        url: '/analyze/:id',
        templateUrl: 'dynexp/dual_channel_optical_cal_v2/views/analyze.html'
      });

    }
  ]);