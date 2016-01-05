(function () {
  'use strict';

  var App = window.App = angular.module('OpticalTest', [
    'ui.router',
    'ngResource',
    'http-auth-interceptor',
    'angularMoment'
  ]);

  App.value('host', 'http://' + window.location.hostname);

})();