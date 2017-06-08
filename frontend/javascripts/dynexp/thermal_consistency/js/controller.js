(function() {
  angular.module('dynexp.thermal_consistency')
    .controller('ThermalConsistencyCtrl', [
      '$scope',
      '$window',
      'dynexpExperimentService',
      '$state',
      '$stateParams',
      'Status',
      'dynexpGlobalService',
      'host',
      '$http',
      'ThermalConsistencyConstants',
      'dynexpDeviceInfo',
      '$timeout',
      '$rootScope',
      '$uibModal',
      function ThermalConsistencyCtrl($scope, $window, Experiment, $state, $stateParams, Status, GlobalService,
        host, $http, CONSTANTS, DeviceInfo, $timeout, $rootScope, $uibModal) {

        $scope.$on('$destroy', function() {
          if ($scope.timeout) {
            $timeout.cancel($scope.timeout);
          }
        });

        $scope.error = true;
        $scope.cancel = false;
        $scope.loop = [];
        $scope.CONSTANTS = CONSTANTS;
        $scope.isFinite = isFinite;
        $('.content').addClass('analyze');

        GlobalService.isDualChannel(function(it_is) {
          $scope.is_dual_channel = it_is;
        });

        function getExperiment(exp_id, cb) {
          Experiment.get(exp_id).then(function(resp) {
            $scope.experiment = resp.data.experiment;
            if (cb) cb(resp.data.experiment);
          });
        }

        for (var i = 0; i < 8; i++) {
          $scope.loop.push(i);
        }

        $scope.$watch(function() {
          return Status.getData();
        }, function(data, oldData) {
          if (!data) return;
          if (!data.experiment_controller) return;
          if (!oldData) return;
          if (!oldData.experiment_controller) return;

          $scope.data = data;
          $scope.state = data.experiment_controller.machine.state;
          $scope.old_state = oldData.experiment_controller.machine.state;
          $scope.timeRemaining = GlobalService.timeRemaining(data);

          if (data.experiment_controller.experiment && !$scope.experiment) {
            getExperiment(data.experiment_controller.experiment.id);
          }

          if ($scope.state === 'idle' && $scope.old_state !== 'idle') {
            // exp complete
            checkExperimentStatus();
          }

          if ($scope.state === 'idle' && $scope.old_state === 'idle' && $state.current.name === 'exp-running') {
            getExperiment(data.experiment_controller.experiment.id);
            if ($scope.experiment.completion_status === 'failure') {
              $state.go('thermal_consistency.analyze', { id: $scope.experiment.id });
            }
          }



          if ($state.current.name === 'analyze') Status.stopSync();

        }, true);

        function checkExperimentStatus() {
          Experiment.get($scope.experiment.id).then(function(resp) {
            $scope.experiment = resp.data.experiment;
            if ($scope.experiment.completed_at) {
              $state.go('thermal_consistency.analyze', { id: $scope.experiment.id });
            } else {
              $timeout(checkExperimentStatus, 1000);
            }
          });
        }


        $scope.checkMachineStatus = function() {

          DeviceInfo.getInfo($scope.check).then(function(deviceStatus) {
            // Incase connected
            if ($scope.modal) {
              $scope.modal.close();
              $scope.modal = null;
            }

            if (deviceStatus.data.optics.lid_open === "true" || deviceStatus.data.lid.open === true) { // lid is open
              $scope.error = true;
              $scope.lidMessage = "Close lid to begin.";
            } else {
              $scope.error = false;
            }
          }, function(err) {
            // Error
            $scope.error = true;
            $scope.lidMessage = "Cant connect to machine.";

            if (err.status === 500) {

              if (!$scope.modal) {
                var scope = $rootScope.$new();
                scope.message = {
                  title: "Cant connect to machine.",
                  body: err.data.errors || "Error"
                };

                $scope.modal = $uibModal.open({
                  templateUrl: 'dynexp/thermal_consistency/views/modal-error.html',
                  scope: scope
                });
              }
            }
          });

          $scope.timeout = $timeout($scope.checkMachineStatus, 1000);
        };

        $scope.checkMachineStatus();

        $scope.analyzeExperiment = function() {
          $scope.analyzing = true;
          if (!$scope.analyzedExp) {
            getExperiment($stateParams.id, function(exp) {
              if (exp.completion_status === 'success') {
                Experiment.analyze($stateParams.id)
                  .then(function(resp) {
                    console.log(resp);
                    if (resp.status == 200) {
                      $scope.analyzedExp = resp.data;
                      $scope.tm_values = GlobalService.getTmValues(resp.data);
                      $scope.analyzing = false;
                    } else if (resp.status == 202) {
                      $timeout($scope.analyzeExperiment, 1000);
                    }
                  })
                  .catch(function(resp) {
                    console.log(resp);
                    if (resp.status == 500) {
                      $scope.custom_error = resp.data.errors || "An error occured while trying to analyze the experiment results.";
                      $scope.analyzing = false;
                    } else if (resp.status == 503) {
                      $timeout($scope.analyzeExperiment, 1000);
                    }
                  });
              } else {
                $scope.analyzing = false;
              }
            });
          }
        };

        $scope.lidHeatPercentage = function() {
          if (!$scope.experiment) return 0;
          if (!$scope.data) return 0;
          return ($scope.data.lid.temperature / $scope.experiment.protocol.lid_temperature);
        };

        $scope.blockHeatPercentage = function() {
          var blockHeat = $scope.getBlockHeat();
          if (!blockHeat) return 0;
          if (!$scope.experiment) return 0;
          return ($scope.data.heat_block.temperature / blockHeat);
        };

        $scope.getBlockHeat = function() {
          if (!$scope.experiment) return;
          if (!$scope.experiment.protocol.stages[0]) return;
          if (!$scope.experiment.protocol.stages[0].stage.steps[0]) return;
          if (!$scope.currentStep()) return;
          return $scope.currentStep().temperature;
        };

        $scope.createExperiment = function() {
          Experiment.create({ guid: 'thermal_consistency', name: 'thermal_consistency' }).then(function(resp) {
            $timeout.cancel($scope.timeout);
            Experiment.startExperiment(resp.data.experiment.id).then(function() {
              $scope.experiment = resp.data.experiment;
              $state.go('thermal_consistency.exp-running');
            });
          });
        };

        $scope.cancelExperiment = function() {
          Experiment.stopExperiment($scope.experiment_id).then(function() {
            $state.go('settings.root');
          });
        };

        $scope.isCollectingData = function() {
          if (!$scope.data) return false;
          if (!$scope.data.optics) return false;
          return ($scope.data.optics.collect_data === 'true');
        };

        $scope.currentStep = function() {
          if (!$scope.experiment) return;
          if (!$scope.data) return;
          if (!$scope.data.experiment_controller) return;
          if (!$scope.data.experiment_controller.experiment) return;
          var step_id = parseInt($scope.data.experiment_controller.experiment.step.id);
          if (!step_id) return;
          var steps = GlobalService.getExperimentSteps($scope.experiment);
          return _.find(steps, { id: step_id });

        };

        $scope.finalStepHoldTime = function() {
          if (!$scope.experiment) return 0;
          if (!$scope.data) return 0;
          if (!$scope.data.experiment_controller) return 0;
          if (!$scope.data.experiment_controller.experiment) return 0;

          var step_id = parseInt($scope.data.experiment_controller.experiment.step.id);
          var steps = $scope.experiment.protocol.stages[0].stage.steps;
          return steps[steps.length - 1].step.hold_time;
        };

        $scope.maxDeltaTm = function() {
          if (!$scope.tm_values) return 0;
          var max_delta_tm = GlobalService.getMaxDeltaTm($scope.tm_values);
          return max_delta_tm;
        };

      }
    ]);
})();
