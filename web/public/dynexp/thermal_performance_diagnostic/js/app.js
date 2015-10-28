(function () {
  'use strict';

  var App = window.App = angular.module('ThermalDiagnosticApp', [
    'ui.router',
    'ngResource'
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
        templateUrl: './views/loading.html',
        controller: 'DiagnosticInitCtrl'
      })
      .state('diagnostic', {
        url: '/thermal-performance-diagnostic/:id',
        templateUrl: './views/diagnostic.html',
        controller: 'DiagnosticWizardCtrl'
      });

    }
  ]);

  App.controller('DiagnosticInitCtrl', [
    '$scope',
    'Experiment',
    '$state',
    function ($scope, Experiment, $state) {
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
    }
  ]);

  App.controller('DiagnosticWizardCtrl', [
    '$scope', 'Experiment', 'Status', '$interval', 'DiagnosticWizardService', '$stateParams', '$state',
    function($scope, Experiment, Status, $interval, DiagnosticWizardService, $params, $state) {
      var fetchingTemps, fetchTempLogs, getExperiment, pollTemperatures, stopPolling, tempPoll, analyzeExperiment;
      Status.startSync();
      $scope.$on('$destroy', function() {
        Status.stopSync();
        return stopPolling();
      });
      tempPoll = null;
      $scope.lidTemps = null;
      $scope.blockTemps = null;
      fetchingTemps = false;
      fetchTempLogs = function() {
        if(!fetchingTemps) {
          fetchingTemps = true;
          Experiment.getTemperatureData($scope.experiment.id).then(function(resp) {
            var ref, ref1;
            if (resp.data.length === 0) return;
            $scope.lidTemps = DiagnosticWizardService.temperatureLogs(resp.data).getLidTemps();
            $scope.blockTemps = DiagnosticWizardService.temperatureLogs(resp.data).getBlockTemps();
            return $scope.elapsedTime = ((ref = resp.data[resp.data.length - 1]) != null ? (ref1 = ref.temperature_log) != null ? ref1.elapsed_time : void 0 : void 0) || 0;
          })
          .finally(function () {
            fetchingTemps = false;
          });
        }
      };
      pollTemperatures = function() {
        if (!tempPoll) tempPoll = $interval(fetchTempLogs, 3000);
      };
      stopPolling = function() {
        $interval.cancel(tempPoll);
        tempPoll = null;
      };
      getExperiment = function(cb) {
        cb = cb || angular.noop;
        return Experiment.get({
          id: $params.id
        }).$promise.then(function(resp) {
          return cb(resp);
        });
      };
      analyzeExperiment = function () {
        Experiment.analyze($params.id).then(function (resp) {
          $scope.analyzedExp = resp.data;
          console.log(resp.data);
        });
      };

      $scope.$watch(function() {
        return Status.getData();
      }, function(data, oldData) {
        var exp, newState, oldState, ref, ref1;
        if (!data) {
          return;
        }
        if (!data.experimentController) {
          return;
        }
        if (!data.experimentController.machine) {
          return;
        }
        newState = data.experimentController.machine.state;
        oldState = oldData != null ? (ref = oldData.experimentController) != null ? (ref1 = ref.machine) != null ? ref1.state : void 0 : void 0 : void 0;
        $scope.status = newState === 'Running' ? data.experimentController.machine.thermal_state : newState;
        if (!$scope.experiment) {
          getExperiment(function(resp) {
            $scope.experiment = resp.experiment;
            if (resp.experiment.started_at && !resp.experiment.completed_at) {
              pollTemperatures();
            }
            if (resp.experiment.started_at && resp.experiment.completed_at) {
              fetchTempLogs();
              analyzeExperiment();
            }
          });
        }
        if (newState === 'Idle' && oldState !== 'Idle' && $params.id) {
          stopPolling();
          Status.stopSync();
          analyzeExperiment();
          getExperiment(function(resp) {
            $scope.experiment = resp.experiment;
          });
        }
      });

      $scope.stopExperiment = function() {
        Experiment.stopExperiment({
          id: $scope.experiment.id
        }).then(function() {
          window.location.assign('/');
        });
      };
    }
  ]);

})();