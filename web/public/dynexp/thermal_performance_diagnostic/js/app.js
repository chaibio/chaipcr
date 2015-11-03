(function () {
  'use strict';

  var App = window.App = angular.module('ThermalDiagnosticApp', [
    'ui.router',
    'ngResource',
    'http-auth-interceptor'
  ]);

  App.value('host', 'http://'+window.location.hostname);

  App.config([
    '$stateProvider',
    '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {

      $urlRouterProvider.otherwise('diagnostic-initialization');

      $stateProvider
      .state('diagnostic-initialization', {
        url: '/diagnostic-initialization',
        templateUrl: './views/init.html'
      })
      .state('diagnostic', {
        url: '/thermal-performance-diagnostic/:id',
        templateUrl: './views/diagnostic.html'
      });

    }
  ]);

  App.controller('DiagnosticInitCtrl', [
    '$scope',
    'Experiment',
    '$state',
    function ($scope, Experiment, $state) {

      $scope.proceed = function () {
        var exp;
        exp = new Experiment({
          experiment: {
            guid: 'thermal_performance_diagnostic'
          }
        });
        exp.$save().then(function(resp) {
          $scope.experiment = resp.experiment;
          Experiment.startExperiment(resp.experiment.id).then(function() {
            $state.go('diagnostic', {
              id: resp.experiment.id
            });
          });
        });
      };

    }
  ]);

})();