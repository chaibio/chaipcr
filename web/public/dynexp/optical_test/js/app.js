(function () {
  'use strict';

  var App = window.App = angular.module('OpticalTest', [
    'ui.router',
    'ngResource',
    'http-auth-interceptor',
    'angularMoment',
    'ui.bootstrap',
    'status.service',
    'global.service',
    'wizard.header',
    'auth',
  ]);

  App.run(['Status', function (Status) {
    Status.startSync();
  }]);

  App.value('host', 'http://' + window.location.hostname);

})();
