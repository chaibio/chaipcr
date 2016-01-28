(function () {
  'use strict';

  var App = window.App = angular.module('OpticalCalibrationApp', [
    'ui.router',
    'ngResource',
    'http-auth-interceptor',
    'angularMoment',
    'ui.bootstrap',
    'wizard.header',
    'status.service',
    'global.service',
  ]);

  App.value('host', 'http://'+window.location.hostname);

  App.run(['Status', function (Status) {
    Status.startSync();
  }]);

})();
