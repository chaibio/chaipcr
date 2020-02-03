  angular.module('dynexp.optical_test_dual_channel')
    .controller('OpticalTestDualChannelCtrl', [
      '$scope',
      '$window',
      'dynexpExperimentService',
      '$state',
      'Status',
      'dynexpGlobalService',
      'OpticalTestDualChannelConstants',
      'host',
      '$http',
      '$interval',
      '$uibModal',
      '$rootScope',
      '$timeout',
      function OpticalTestDualChannelCtrl($scope, $window, Experiment, $state, Status, GlobalService, Constants,
        host, $http, $interval, $uibModal, $rootScope, $timeout) {

        var checkMachineStatusInterval = null;

        $scope.$on('$destroy', function () {
          if (checkMachineStatusInterval) {
            $timeout.cancel(checkMachineStatusInterval);
          }
        });

        var errorModal = null;
        var pages = [
          'optical_test_2ch.intro',
          'optical_test_2ch.page-2',
          'optical_test_2ch.page-3',
          'optical_test_2ch.page-4',
          'optical_test_2ch.page-5',
          'optical_test_2ch.page-6',
          'optical_test_2ch.page-7',
          'optical_test_2ch.page-8',
          'optical_test_2ch.page-9',
        ];

        var ERROR_TYPES = ['OFFLINE', 'CANT_CREATE_EXPERIMENT', 'CANT_START_EXPERIMENT', 'LID_OPEN', 'UNKNOWN_ERROR'];
        $scope.errors = {};
        $scope.created = false;
        $scope.CONSTANTS = Constants;

        var current_exp_id = 0;
        var cal_exp_id = 0;

        $scope.$on('status:data:updated', function(e, data, oldData) {
          checkMachineStatus(data);
          if (!data) return;
          if (!data.experiment_controller) return;
          if (!oldData) return;
          if (!oldData.experiment_controller) return;

          $scope.data = data;
          $scope.state = data.experiment_controller.machine.state;
          $scope.timeRemaining = GlobalService.timeRemaining(data);

          if ($scope.state === 'paused') {
            var pausedPages = [
              'optical_test_2ch.page-4',
              'optical_test_2ch.page-6',
              'optical_test_2ch.page-8',
            ];
            if (pausedPages.indexOf($state.current.name) > -1) {
              $scope.next();
            }
          }

          current_exp_id = $scope.experiment ? $scope.experiment.id : null;
          cal_exp_id = (!cal_exp_id) ? current_exp_id : cal_exp_id;
          var running_exp_id = oldData.experiment_controller.experiment ? oldData.experiment_controller.experiment.id : null;
          var is_current_exp = (parseInt(current_exp_id) === parseInt(running_exp_id)) && (running_exp_id !== null);

          if (data.experiment_controller.experiment && !$scope.experiment) {
            Experiment.get(data.experiment_controller.experiment.id).then(function(resp) {
              $scope.experiment = resp.data.experiment;
            });
          }

          if ($scope.state === 'idle' && (oldData.experiment_controller.machine.state !== 'idle') && is_current_exp) {
            // experiment is complete
            checkExperimentStatus();
          }
        });

        $scope.$on('status:data:error', function(e, data, oldData) {
          var err = data;
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
                templateUrl: 'dynexp/optical_test_dual_channel/views/modal-error.html',
                scope: scope
              });
            }
          }
        });

        function checkExperimentStatus() {
          Experiment.get(cal_exp_id).then(function(resp) {
            $scope.experiment = resp.data.experiment;
            if ($scope.experiment.completed_at) {
              $state.go('optical_test_2ch.page-9', { id: cal_exp_id });
            } else {
              $timeout(checkExperimentStatus, 1000);
            }
          });
        }

        function checkMachineStatus(deviceStatus) {
          // In case connected
          current_exp_id = $scope.experiment ? $scope.experiment.id : null;
          cal_exp_id = (!cal_exp_id) ? current_exp_id : cal_exp_id;
          var running_exp_id = deviceStatus.experiment_controller.experiment ? deviceStatus.experiment_controller.experiment.id : null;
          var is_current_exp = (running_exp_id !== null) && parseInt(current_exp_id) === parseInt(running_exp_id);

          if (errorModal) {
            errorModal.close();
            errorModal = null;
          }

          if ($scope.errors.OFFLINE) {
            delete $scope.errors.OFFLINE;
          }

          if (deviceStatus.optics.lid_open === "true" || deviceStatus.optics.lid_open === true) { // lid is open
            $scope.errors.LID_OPEN = "Close lid to begin.";
          } else {
            delete $scope.errors.LID_OPEN;
          }
        }

        // checkMachineStatusInterval = $interval(checkMachineStatus, 1000);

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

        $scope.next = function() {
          var pageIndex = pages.indexOf($state.current.name);
          var params = {};
          if (pageIndex === (pages.length - 1))
            params.id = $scope.experiment.id;

          $state.go(pages[pageIndex + 1], params);
        };

        $scope.createExperiment = function() {
          if (!$scope.created) {
            Experiment.create({ guid: 'optical_test_dual_channel', name: 'optical_test_dual_channel' })
              .then(function(resp) {
                Experiment.startExperiment(resp.data.experiment.id)
                  .then(function() {
                    $scope.created = true;
                    $scope.experiment = resp.data.experiment;
                    $scope.errors = {};
                    $scope.next();
                  })
                  .catch(function(resp) {
                    $scope.errors.CANT_START_EXPERIMENT = "Can't start experiment.";
                  });
              })
              .catch(function(err) {
                $scope.errors.CANT_CREATE_EXPERIMENT = "Unable to create experiment.";
              });
          }
        };

        $scope.resumeExperiment = function() {
          Experiment.resumeExperiment().then(function() {
            $scope.next();
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
          // var step_id = parseInt($scope.data.experiment_controller.experiment.step.id);
          var step_number = parseInt($scope.data.experiment_controller.experiment.step.number);
          return step_number;
          // if (!step_id) return;
          // return $scope.experiment.protocol.stages[0].stage.steps[step_id - 1].step;

        };

        $scope.finalStepHoldTime = function() {
          if (!$scope.experiment) return 0;
          if (!$scope.data) return 0;
          if (!$scope.data.experiment_controller) return 0;
          if (!$scope.data.experiment_controller.experiment) return 0;

          var steps = $scope.experiment.protocol.stages[0].stage.steps;
          return steps[steps.length - 1].step.hold_time || 0;
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
