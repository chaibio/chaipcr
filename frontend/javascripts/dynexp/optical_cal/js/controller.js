(function() {
  angular.module('dynexp.optical_cal').controller('OpticalCalibrationCtrl', [
    '$scope',
    '$window',
    'dynexpExperimentService',
    '$state',
    'Status',
    'dynexpGlobalService',
    'host',
    '$http',
    'dynexpDeviceInfo',
    '$interval',
    '$uibModal',
    '$rootScope',
    '$timeout',
    function OpticalCalibrationCtrl($scope, $window, Experiment, $state, Status, GlobalService,
      host, $http, DeviceInfo, $interval, $uibModal, $rootScope, $timeout) {


      var ERROR_TYPES = ['OFFLINE', 'CANT_CREATE_EXPERIMENT', 'CANT_START_EXPERIMENT', 'LID_OPEN', 'UNKNOWN_ERROR', 'ANOTHER_EXPERIMENT_RUNNING'];
      var checkMachineStatusInterval = null;
      $scope.analyze_failed = false;

      $scope.$on('$destroy', function() {
        if (checkMachineStatusInterval) {
          $timeout.cancel(checkMachineStatusInterval);
        }
      });

      var errorModal = null;
      $scope.cancel = false;
      $scope.errors = {};

      function checkMachineStatus() {
        Status
          .fetch()
          .then(function(deviceStatus) {
            // In case connected

            if (errorModal) {
              errorModal.close();
              errorModal = null;
            }

            var this_exp_id = $scope.experiment ? $scope.experiment.id : null;
            var running_exp_id = deviceStatus.experiment_controller.experiment ? deviceStatus.experiment_controller.experiment.id : null;
            var is_current_exp = (parseInt(this_exp_id) === parseInt(running_exp_id)) && (running_exp_id !== null);

            if (deviceStatus.experiment_controller.machine.state !== 'idle' && running_exp_id !== null && !is_current_exp) {
              $scope.errors.ANOTHER_EXPERIMENT_RUNNING = "Another experiment is running.";
            } else {
              delete $scope.errors.ANOTHER_EXPERIMENT_RUNNING;
            }

            if ($scope.errors.OFFLINE) {
              delete $scope.errors.OFFLINE;
            }

            if (deviceStatus.optics.lid_open === "true" || deviceStatus.optics.lid_open === true) { // lid is open
              $scope.errors.LID_OPEN = "Close lid to begin.";
            } else {
              delete $scope.errors.LID_OPEN;
            }
          })
          .catch(function(err) {
            // Error
            $scope.errors.OFFLINE = "Can't connect to the machine.";

            if (err.status === 500) {

              if (!errorModal) {
                var scope = $rootScope.$new();
                scope.message = {
                  title: "Cant connect to machine.",
                  body: err.data.errors || "Error"
                };

                errorModal = $uibModal.open({
                  templateUrl: 'dynexp/optical_cal/views/modal-error.html',
                  scope: scope
                });
              }
            }
          });
      }

      checkMachineStatusInterval = $interval(checkMachineStatus, 1000);

      $scope.$watch(function() {
        return Status.getData();
      }, function(data, oldData) {
        if (!data) return;
        if (!data.experiment_controller) return;
        if (!oldData) return;
        if (!oldData.experiment_controller) return;

        $scope.data = data;
        $scope.state = data.experiment_controller.machine.state;
        $scope.timeRemaining = GlobalService.timeRemaining(data);

        if ($scope.isCollectingData() && $state.current.name === 'optical_cal.step-3') {
          $state.go('optical_cal.step-3-reading');
        }
        if (!$scope.isCollectingData() && ($state.current.name === 'optical_cal.step-3-reading')) {
          $state.go('optical_cal.step-4');
        }

        var this_exp_id = $scope.experiment ? $scope.experiment.id : null;
        var running_exp_id = oldData.experiment_controller.experiment ? oldData.experiment_controller.experiment.id : null;
        var is_current_exp = (parseInt(this_exp_id) === parseInt(running_exp_id)) && (running_exp_id !== null);

        if ($scope.state === 'idle' && (oldData.experiment_controller.machine.state === 'idle') && $state.current.name === 'optical_cal.step-3') {
          Experiment.get($scope.experiment.id).then(function(resp) {
            $scope.experiment = resp.data.experiment;
            if ($scope.experiment.completion_status === 'failure') {
              $state.go('optical_cal.step-6');
              return;
            }
          });
        }

        // if ($scope.state === 'idle' && (oldData.experiment_controller.machine.state !== 'idle' || $state.current.name === 'optical_cal.step-5')) {
        if ($scope.state === 'idle' && (oldData.experiment_controller.machine.state !== 'idle') && is_current_exp) {
          // experiment is complete
          checkExperimentStatus();
        }
        if ($state.current.name === 'optical_cal.step-3' || $state.current.name === 'optical_cal.step-3-reading') {
          console.log($scope.timeRemaining);
          if ($scope.timeRemaining >= $scope.finalStepHoldTime()) {
            $scope.timeRemaining = ($scope.timeRemaining - $scope.finalStepHoldTime());
          }
        }
      }, true);

      function checkExperimentStatus() {
        Experiment.get($scope.experiment.id).then(function(resp) {
          $scope.experiment = resp.data.experiment;
          if ($scope.experiment.completed_at) {
            if ($scope.experiment.completion_status !== 'success') {
              $state.go('optical_cal.step-6');
              return;
            }
            $scope.analyzeExperiment();
          } else {
            $timeout(checkExperimentStatus, 1000);
          }
        });
      }

      $scope.analyzeExperiment = function() {
        Experiment.analyze($scope.experiment.id).then(function(resp) {
            if (resp.status == 200) {
              $state.go('optical_cal.step-6');
              $scope.result = resp.data;
              $scope.valid = resp.data.valid;
              if ($scope.valid) $http.put(host + '/settings', { settings: { "calibration_id": $scope.experiment.id } });
              $scope.analyze_failed = false;
            }
            if (resp.status == 202) {
              $timeout($scope.analyzeExperiment, 1000);
            }
          })
          .catch(function(resp) {
            if (resp.status == 503) {
              $timeout($scope.analyzeExperiment, 1000);
            } else if (resp.status == 500) {
              $scope.valid = false;
              $scope.result = resp.data;
              $scope.analyze_failed = true;
            }
          });
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
        Experiment.create({ guid: 'optical_cal', name: 'optical_cal' }).then(function(resp) {
          Experiment.startExperiment(resp.data.experiment.id).then(function() {
            $scope.experiment = resp.data.experiment;
            $state.go('optical_cal.step-3');
          });
        });
      };

      $scope.resumeExperiment = function() {
        Experiment.resumeExperiment().then(function() {
          $state.go('optical_cal.step-5');
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
        return $scope.experiment.protocol.stages[0].stage.steps[step_id - 1].step;

      };

      $scope.finalStepHoldTime = function() {
        if (!$scope.experiment) return 0;
        if (!$scope.data) return 0;
        if (!$scope.data.experiment_controller) return 0;
        if (!$scope.data.experiment_controller.experiment) return 0;

        var step_id = parseInt($scope.data.experiment_controller.experiment.step.id);
        var steps = $scope.experiment.protocol.stages[0].stage.steps;
        console.log(steps[steps.length - 1].step.hold_time);
        return steps[steps.length - 1].step.hold_time;

      };

      $scope.getErrors = function() {
        var errors = [];
        for (var i = ERROR_TYPES.length - 1; i >= 0; i--) {
          if ($scope.errors[ERROR_TYPES[i]])
            errors.push($scope.errors[ERROR_TYPES[i]]);
        }
        return errors;
      };

    }
  ]);
})();
