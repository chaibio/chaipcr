(function () {
  'use strict';

  var App = window.App = angular.module('ThermalConsistency', [
    'ui.router',
    'ngResource',
    'http-auth-interceptor',
    'angularMoment',
    'ui.bootstrap',
    'auth',
    'global.service',
    'status.service',
    'experiment.service',
    'wizard.header',
  ]);

  App.run([
    'Status',
    function (Status) {
      Status.startSync();
    }
  ]);

  App.value('host', 'http://' + window.location.hostname);

})();
