(function () {


  App.controller('DiagnosticWizardCtrl', [
    '$scope', 'Experiment', 'Status', '$interval', 'DiagnosticWizardService', '$stateParams', '$state', 'CONSTANTS',
    function ($scope, Experiment, Status, $interval, DiagnosticWizardService, $params, $state, CONSTANTS) {

      Status.startSync();
      $scope.$on('$destroy', function() {
        Status.stopSync();
        stopPolling();
        cancelAnimation();
      });

      $scope.CONSTANTS = CONSTANTS;
      $scope.lidTemps = null;
      $scope.blockTemps = null;
      var fetchingTemps = false;
      var temperatureLogs = [];
      var tempPoll = null;
      var animation;
      var oldData;

      function fetchTempLogs () {
        if(!fetchingTemps) {
          fetchingTemps = true;
          var last_elapsed_time = temperatureLogs[temperatureLogs.length-1]? temperatureLogs[temperatureLogs.length-1].temperature_log.elapsed_time : 0;
          Experiment.getTemperatureData($scope.experiment.id, {starttime: last_elapsed_time}).then(function(resp) {
            if (resp.data.length === 0) return;
            var data = resp.data;
            // if ($scope.max_x) {
            //   var diff = $scope.max_x - (resp.data[0].temperature_log.elapsed_time);
            //   if (diff > 0) {
            //     data = _.map(angular.copy(resp.data), function (datum) {
            //       datum.temperature_log.elapsed_time = datum.temperature_log.elapsed_time + diff;
            //       return datum;
            //     });
            //   }
            // }
            updateData(oldData, angular.copy(data));
            oldData = resp.data;
          })
          .finally(function () {
            fetchingTemps = false;
          });
        }
      };

      function updateData (old, data) {
        animate(angular.copy(temperatureLogs), angular.copy(data));
        temperatureLogs = temperatureLogs.concat(data);
        $scope.lidTemps = DiagnosticWizardService.temperatureLogs(temperatureLogs).getLidTemps();
        $scope.blockTemps = DiagnosticWizardService.temperatureLogs(temperatureLogs).getBlockTemps();
        temperatureLogs = DiagnosticWizardService.temperatureLogs(temperatureLogs).getLast30seconds();
      }

      function animate (old, data) {

        cancelAnimation();
        var calibration = 50;
        var duration = 1500;//ms
        var calibration_index = 0;

        old = old.length > 0? old : data;
        $scope.min_x = $scope.min_x || old[0].temperature_log.elapsed_time;
        $scope.max_x = $scope.max_x ||old[old.length-1].temperature_log.elapsed_time;

        var x_diff = (data[data.length-1].temperature_log.elapsed_time) - $scope.max_x;
        var x_increment;
        x_increment = x_increment || x_diff/calibration;

        animation = $interval(function () {

          if (calibration_index === calibration) {
            cancelAnimation();
          }

          if ($scope.max_x/1000 > 30) $scope.min_x += x_increment;
          $scope.max_x += x_increment;
          calibration_index ++;
        }, duration/calibration);

      }

      function cancelAnimation () {
        $interval.cancel(animation);
      }

      function pollTemperatures () {
        if (!tempPoll) tempPoll = $interval(fetchTempLogs, 1000);
      };
      function stopPolling () {
        $interval.cancel(tempPoll);
        tempPoll = null;
      };
      function getExperiment (cb) {
        if (!$params.id) return;
        cb = cb || angular.noop;
        return Experiment.get({
          id: $params.id
        }).$promise.then(function(resp) {
          return cb(resp);
        });
      };
      function analyzeExperiment () {
        if (!$scope.analyzedExp) {
          Experiment.analyze($params.id).then(function (resp) {
            $scope.analyzedExp = resp.data;
          });
        }
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
        $scope.heat_block_temp = data.heatblock.temperature
        $scope.lid_temp = data.lid.temperature
        if (data.experimentController.expriment) $scope.elapsedTime = data.experimentController.expriment.run_duration

        if (!$scope.experiment) {
          getExperiment(function(resp) {
            $scope.experiment = resp.experiment;
            if (resp.experiment.started_at && !resp.experiment.completed_at) {
              pollTemperatures();
            }
            if (resp.experiment.started_at && resp.experiment.completed_at) {
              fetchTempLogs();
              analyzeExperiment();
              Status.stopSync();
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