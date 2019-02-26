(function() {

  angular.module('dynexp.thermal_performance_diagnostic')
    .filter('fixedDate', [
    function() {
      return function(value) {
        var space_index = value.toString().indexOf(' ');
        var time_body = value.toString().substring(0, space_index);
        var date_body = value.toString().substring(space_index, value.length);

        if(time_body.indexOf(':')){
          return date_body + ' ' + time_body;
        }

        return value;
      };
    }
  ]);


  angular.module('dynexp.thermal_performance_diagnostic')
    .controller('DiagnosticWizardCtrl', [
      '$scope',
      'dynexpExperimentService',
      'Status',
      '$interval',
      '$timeout',
      'DiagnosticWizardService',
      '$stateParams',
      '$state',
      'ThermalPerformanceDiagnosticConstants',
      function($scope, Experiment, Status, $interval, $timeout, DiagnosticWizardService, $params, $state, CONSTANTS) {

        $scope.CONSTANTS = CONSTANTS;
        $scope.lidTemps = null;
        $scope.blockTemps = null;
        var fetchingTemps = false;
        var temperatureLogs = [];
        var tempPoll = null;
        var animation;

        function fetchTempLogs() {
          if (!fetchingTemps) {
            fetchingTemps = true;
            var last_elapsed_time = temperatureLogs[temperatureLogs.length - 1] ? temperatureLogs[temperatureLogs.length - 1].temperature_log.elapsed_time : -1;
            Experiment.getTemperatureData($scope.experiment.id, { starttime: last_elapsed_time * 1 + 1 })
              .then(function(resp) {
                if (resp.data.length === 0) return;
                var data = resp.data;
                updateData(angular.copy(data));
              })
              .finally(function() {
                fetchingTemps = false;
              });
          }
        }

        function updateData(data) {
          animate(angular.copy(temperatureLogs), angular.copy(data));
          temperatureLogs = temperatureLogs.concat(data);

          $scope.lidTemps = DiagnosticWizardService.temperatureLogs(temperatureLogs).getLidTemps();
          $scope.blockTemps = DiagnosticWizardService.temperatureLogs(temperatureLogs).getBlockTemps();
          // temperatureLogs = DiagnosticWizardService.temperatureLogs(temperatureLogs).getLast30seconds();
        }

        function animate(old, data) {

          cancelAnimation();
          var calibration = 50;
          var duration = 2500; //ms
          var calibration_index = 0;

          old = old.length > 0 ? old : data;
          $scope.min_x = $scope.min_x || old[0].temperature_log.elapsed_time;
          $scope.max_x = $scope.max_x || old[old.length - 1].temperature_log.elapsed_time;

          var x_diff = (data[data.length - 1].temperature_log.elapsed_time) - $scope.max_x;
          var x_increment = x_diff / calibration;
          var old_max_x = $scope.max_x;

          animation = $interval(function() {

            if (calibration_index === calibration) {
              cancelAnimation();
            }

            if ($scope.max_x / 1000 > 30)
              $scope.min_x = ($scope.min_x * 1 + x_increment * 1);
            if ($scope.max_x - old_max_x < x_diff)
              $scope.max_x += x_increment;

            $scope.$broadcast('update:rainbow:chart');
            calibration_index++;
          }, duration / calibration);

        }

        function cancelAnimation() {
          $interval.cancel(animation);
        }

        function pollTemperatures() {
          if (!tempPoll) tempPoll = $interval(fetchTempLogs, 1000);
        }

        function stopPolling() {
          $interval.cancel(tempPoll);
          tempPoll = null;
        }

        function getExperiment(cb) {
          if (!$params.id) return;
          cb = cb || angular.noop;
          return Experiment.get($params.id).then(function(resp) {
            return cb(resp.data);
          });
        }

        function analyzeExperiment() {
          if (!$scope.analyzedExp) {
            Experiment.analyze($params.id).then(function(resp) {
                if (resp.status == 200) {
                  $scope.analyzedExp = resp.data;
                  console.log($scope.analyzedExp);
                } else if (resp.status == 202) {
                  $timeout(analyzeExperiment, 1000);
                }
              })
              .catch(function(resp) {
                console.log(resp);
                if (resp.status == 500) {
                  $scope.custom_error = resp.data.errors || "An error occured while trying to analyze the experiment results.";
                  //$scope.analyzedExp = " ";
                } else if (resp.status == 503) {
                  $timeout(analyzeExperiment, 1000);
                }

              });
          }
        }

        $scope.$watch(function() {
          return Status.getData();
        }, function(data, oldData) {
          var exp, newState, oldState, ref, ref1;
          if (!data) {
            return;
          }
          if (!data.experiment_controller) {
            return;
          }
          if (!data.experiment_controller.machine) {
            return;
          }
          newState = data.experiment_controller.machine.state;
          oldState = oldData !== null ? (ref = oldData.experiment_controller) !== null ? (ref1 = ref.machine) !== null ? ref1.state : void 0 : void 0 : void 0;
          $scope.status = newState === 'running' ? data.experiment_controller.machine.thermal_state : newState;
          $timeout(function() {
            $scope.heat_block_temp = data.heat_block.temperature;
            $scope.lid_temp = data.lid.temperature;
          }, 2500);
          if (data.experiment_controller.experiment) $scope.elapsedTime = data.experiment_controller.experiment.run_duration;

          if (!$scope.experiment) {
            getExperiment(function(resp) {
              $scope.experiment = resp.experiment;
              if (resp.experiment.started_at && !resp.experiment.completed_at) {
                pollTemperatures();
              }
              if (resp.experiment.started_at && resp.experiment.completed_at) {
                fetchTempLogs();
                if (resp.experiment.completion_status === 'success') analyzeExperiment();
                Status.stopSync();
              }
            });
          }
          if (newState === 'idle' && oldState !== 'idle' && $params.id) {
            stopPolling();
            Status.stopSync();
            checkExperimentStatus();
          }

          if (newState === 'idle' && oldState == 'idle' && $params.id) {
            getExperiment(function(resp) {
              $scope.experiment = resp.experiment;
              if ($scope.experiment.completion_status === 'failure') {
                stopPolling();
                Status.stopSync();
              }
            });
          }
        });

        function checkExperimentStatus() {
          Experiment.get($scope.experiment.id).then(function(resp) {
            $scope.experiment = resp.data.experiment;
            if ($scope.experiment.completed_at) {
              if ($scope.experiment.completion_status === 'success') {
                analyzeExperiment();
              }
            } else {
              $timeout(checkExperimentStatus, 1000);
            }
          });
        }

        $scope.stopExperiment = function() {
          Experiment.stopExperiment({
            id: $scope.experiment.id
          }).then(function() {
            $state.go('settings.root');
          });
        };

        getExperiment(function(resp) {
          $scope.experiment = resp.experiment;
          console.log($scope.experiment);
        });

        $scope.$on('$destroy', function() {
          stopPolling();
          cancelAnimation();
        });

      }
    ]);

})();
