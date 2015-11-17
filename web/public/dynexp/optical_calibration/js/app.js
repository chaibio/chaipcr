(function () {
  'use strict';

  var App = window.App = angular.module('OpticalCalibrationApp', [
    'ui.router',
    'ngResource',
    'http-auth-interceptor',
    'angularMoment'
  ]);

  App.value('host', 'http://'+window.location.hostname);

  App.config([
    '$stateProvider',
    '$urlRouterProvider',
    function ($stateProvider, $urlRouterProvider) {

      $urlRouterProvider.otherwise('introduction');

      $stateProvider
      .state('introduction', {
        url: '/introduction',
        templateUrl: './views/intro.html'
      })
      .state('step-1', {
        url: '/step-1',
        templateUrl: './views/step-1.html'
      })
      .state('step-2', {
        url: '/step-2',
        templateUrl: './views/step-2.html'
      })
      .state('step-3', {
        url: '/step-3',
        templateUrl: './views/step-3.html'
      })
      .state('step-4', {
        url: '/step-4',
        templateUrl: './views/step-4.html'
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