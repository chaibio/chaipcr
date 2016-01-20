(function () {
  window.App.controller('OpticalCalibrationCtrl', [
    '$scope',
    '$window',
    'Experiment',
    '$state',
    'Status',
    'TestInProgressService',
    'host',
    '$http',
    'DeviceInfo',
    '$timeout',
    '$uibModal',
    '$rootScope',
    function OpticalCalibrationCtrl ($scope, $window, Experiment, $state, Status, TestInProgressService,
      host, $http, DeviceInfo, $timeout, $uibModal, $rootScope) {

      $scope.cancel = false;
      $scope.error = true;

      $scope.$watch(function () {
        return Status.getData();
      }, function (data, oldData) {
        if (!data) return;
        if (!data.experiment_controller) return;
        if (!oldData) return;
        if (!oldData.experiment_controller) return;

        $scope.data = data;
        $scope.state = data.experiment_controller.machine.state;
        $scope.timeRemaining = TestInProgressService.timeRemaining(data);

        if (data.experiment_controller.expriment && !$scope.experiment) {
          TestInProgressService.getExperiment(data.experiment_controller.expriment.id).then(function (exp) {
            $scope.experiment = exp;
          });
        }
        if ($scope.isCollectingData() && $state.current.name === 'step-3') {
          $state.go('step-3-reading');
        }
        if (!$scope.isCollectingData() && ($state.current.name === 'step-3-reading') ) {
          $state.go('step-4');
        }
        if ($scope.state === 'idle' && (oldData.experiment_controller.machine.state !== 'idle' || $state.current.name === 'step-5')) {
          // experiment is complete
          Experiment.analyze($scope.experiment.id).then(function (resp) {
            $scope.result = resp.data;
            $state.go('step-6');
            if(resp.data.valid) $http.put(host + '/settings', {settings: {"calibration_id": $scope.experiment.id}});
          });
        }
        if ($state.current.name === 'step-3' || $state.current.name === 'step-3-reading') {
          $scope.timeRemaining  = ($scope.timeRemaining - $scope.finalStepHoldTime());
        }
      }, true);

      $scope.checkMachineStatus = function() {

        DeviceInfo.getInfo($scope.check).then(function(deviceStatus) {
          // Incase connected
          if($scope.modal) {
              $scope.modal.close();
              $scope.modal = null;
          }

          if(deviceStatus.data.optics.lid_open === "true" || deviceStatus.data.optics.lid_open === true) { // lid is open
            $scope.error = true;
            $scope.lidMessage = "Close lid to begin.";
          } else {
            $scope.error = false;
          }
        }, function(err) {
          // Error
          $scope.error = true;
          $scope.lidMessage = "Cant connect to machine.";

          if(err.status === 500) {

            if(! $scope.modal) {
              var scope = $rootScope.$new();
              scope.message = {
                title: "Cant connect to machine.",
                body: err.data.errors || "Error"
              };

              $scope.modal = $uibModal.open({
                templateUrl: './views/modal-error.html',
                scope: scope
              });
            }
          }
        });

        $scope.timeout = $timeout($scope.checkMachineStatus, 1000);
      };

      $scope.checkMachineStatus();

      $scope.lidHeatPercentage = function () {
        if (!$scope.experiment) return 0;
        if (!$scope.data) return 0;
        return ($scope.data.lid.temperature/$scope.experiment.protocol.lid_temperature);
      };

      $scope.blockHeatPercentage = function () {
        var blockHeat = $scope.getBlockHeat();
        if (!blockHeat) return 0;
        if (!$scope.experiment) return 0;
        return ($scope.data.heat_block.temperature/blockHeat);
      };

      $scope.getBlockHeat = function () {
        if (!$scope.experiment) return;
        if (!$scope.experiment.protocol.stages[0]) return;
        if (!$scope.experiment.protocol.stages[0].stage.steps[0]) return;
        if (!$scope.currentStep()) return;
        return $scope.currentStep().temperature;
      };

      $scope.createExperiment = function () {
        var exp = new Experiment({
          experiment: {guid: 'optical_cal'}
        });
        exp.$save().then(function (resp) {
          $timeout.cancel($scope.timeout);
          Experiment.startExperiment(resp.experiment.id).then(function () {
            $scope.experiment = resp.experiment;
            $state.go('step-3');
          });
        });
      };

      $scope.resumeExperiment = function () {
        Experiment.resumeExperiment().then(function () {
          $state.go('step-5');
        });
      };

      $scope.cancelExperiment = function () {
        Experiment.stopExperiment($scope.experiment_id).then(function () {
          var redirect = '/#/user/settings';
          $window.location = redirect;
        });
      };

      $scope.isCollectingData = function () {
        if (!$scope.data) return false;
        if (!$scope.data.optics) return false;
        return ($scope.data.optics.collect_data === 'true');
      };

      $scope.currentStep = function () {
        if (!$scope.experiment) return;
        if (!$scope.data) return;
        if (!$scope.data.experiment_controller) return;
        if (!$scope.data.experiment_controller.expriment) return;
        var step_id = parseInt($scope.data.experiment_controller.expriment.step.id);
        if (!step_id) return;
        return $scope.experiment.protocol.stages[0].stage.steps[step_id-1].step;

      };

      $scope.finalStepHoldTime = function () {
        if (!$scope.experiment) return 0;
        if (!$scope.data) return 0;
        if (!$scope.data.experiment_controller) return 0;
        if (!$scope.data.experiment_controller.expriment) return 0;

        var step_id = parseInt($scope.data.experiment_controller.expriment.step.id);
        var steps = $scope.experiment.protocol.stages[0].stage.steps;
        return steps[steps.length-1].step.hold_time;

      };

    }
  ]);
})();
