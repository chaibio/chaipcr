(function() {
  window.App.controller('OpticalCalibrationCtrl', [
    '$scope',
    '$window',
    'Experiment',
    '$state',
    'Status',
    'GlobalService',
    'Constants',
    'host',
    '$http',
    '$interval',
    '$uibModal',
    '$rootScope',
    function OpticalCalibrationCtrl($scope, $window, Experiment, $state, Status, GlobalService, Constants,
      host, $http, $interval, $uibModal, $rootScope) {

      var checkMachineStatusInterval = null;
      var errorModal = null;
      var pages = [
        'page-1',
        'page-2',
        'page-3',
        'page-4',
        'page-5',
        'page-6',
        'page-7',
        'page-8',
        'page-9',
      ];

      var ERROR_TYPES = ['OFFLINE', 'CANT_CREATE_EXPERIMENT', 'CANT_START_EXPERIMENT', 'LID_OPEN', 'UNKNOWN_ERROR'];
      $scope.errors = {};

      $scope.$on('status:data:updated', function(e, data, oldData) {
        if (!data) return;
        if (!data.experiment_controller) return;
        if (!oldData) return;
        if (!oldData.experiment_controller) return;

        $scope.data = data;
        $scope.state = data.experiment_controller.machine.state;
        $scope.timeRemaining = GlobalService.timeRemaining(data);

        if ($scope.isCollectingData()) {
          if ($state.current.name === 'page-4')
            $scope.timeRemaining = $scope.timeRemaining - Constants.PAGE_4_HOLDING_TIME;
          if ($state.current.name === 'page-6')
            $scope.timeRemaining = $scope.timeRemaining - Constants.PAGE_6_HOLDING_TIME;
        }

        if ($scope.state === 'paused') {
          var pausedPages = ['page-4', 'page-6', 'page-8'];
          if (pausedPages.indexOf($state.current.name) !== -1) {
            $scope.next();
          }
        }

        if (data.experiment_controller.expriment && !$scope.experiment) {
          Experiment.get(data.experiment_controller.expriment.id).then(function(resp) {
            $scope.experiment = resp.data.experiment;
          });
        }

        if ($scope.state === 'idle' && (oldData.experiment_controller.machine.state !== 'idle')) {
          // experiment is complete
          Experiment.get($scope.experiment.id).then(function(resp) {
            $scope.experiment = resp.data.experiment;
            $state.go('page-9', {id: $scope.experiment.id});
          });
        }
      });

      function checkMachineStatus() {
        Status
          .fetch()
          .then(function(deviceStatus) {
            // In case connected

            if (errorModal) {
              errorModal.close();
              errorModal = null;
            }

            if ($scope.errors['OFFLINE']) {
              delete $scope.errors['OFFLINE'];
            }

            if (deviceStatus.optics.lid_open === "true" || deviceStatus.optics.lid_open === true) { // lid is open
              $scope.errors.LID_OPEN = "Close lid to begin.";
            } else {
              delete $scope.errors['LID_OPEN'];
            }
          })
          .catch(function(err) {
            // Error
            $scope.errors['OFFLINE'] = "Can't connect to the machine.";

            if (err.status === 500) {

              if (!errorModal) {
                var scope = $rootScope.$new();
                scope.message = {
                  title: "Cant connect to machine.",
                  body: err.data.errors || "Error"
                };

                errorModal = $uibModal.open({
                  templateUrl: './views/modal-error.html',
                  scope: scope
                });
              }
            }
          });
      }

      checkMachineStatusInterval = $interval(checkMachineStatus, 1000);

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
        if( pageIndex === (pages.length - 1))
          params.id = $scope.experiment.id;

        $state.go(pages[pageIndex + 1], params);
      };

      $scope.createExperiment = function() {
        Experiment.create({ guid: 'dual_channel_optics_test' })
          .then(function(resp) {
            Experiment.startExperiment(resp.data.experiment.id)
              .then(function() {
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
      };

      $scope.resumeExperiment = function() {
        Experiment.resumeExperiment().then(function() {
          $scope.next();
        });
      };

      $scope.cancelExperiment = function() {
        Experiment.stopExperiment($scope.experiment_id).then(function() {
          var redirect = '/#/settings/';
          $window.location = redirect;
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
        if (!$scope.data.experiment_controller.expriment) return;
        // var step_id = parseInt($scope.data.experiment_controller.expriment.step.id);
        var step_number = parseInt($scope.data.experiment_controller.expriment.step.number);
        return step_number;
        // if (!step_id) return;
        // return $scope.experiment.protocol.stages[0].stage.steps[step_id - 1].step;

      };

      $scope.finalStepHoldTime = function() {
        if (!$scope.experiment) return 0;
        if (!$scope.data) return 0;
        if (!$scope.data.experiment_controller) return 0;
        if (!$scope.data.experiment_controller.expriment) return 0;

        var steps = $scope.experiment.protocol.stages[0].stage.steps;
        return steps[steps.length - 1].step.hold_time || 0;
      };

      $scope.getErrors = function () {
        var errors = [];
        for (var i = ERROR_TYPES.length - 1; i >= 0; i--) {
          if($scope.errors[ERROR_TYPES[i]])
            errors.push($scope.errors[ERROR_TYPES[i]]);
        }
        return errors;
      };

    }
  ]);
})();
