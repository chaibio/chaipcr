(function () {
  'use strict';

  var App = window.App = angular.module('OpticalCalibrationApp', [
    'ui.router',
    'ngResource',
    'http-auth-interceptor',
    'angularMoment',
    'ui.bootstrap'
  ]);

  App.value('host', 'http://'+window.location.hostname);

})();
