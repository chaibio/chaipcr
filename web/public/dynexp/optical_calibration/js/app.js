(function () {
  'use strict';

  var App = window.App = angular.module('OpticalCalibrationApp', [
    'ui.router',
    'ngResource',
    'http-auth-interceptor',
    'angularMoment'
  ]);

  App.value('host', 'http://'+window.location.hostname);

})();