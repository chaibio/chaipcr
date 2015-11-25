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
    function OpticalCalibrationCtrl ($scope, $window, Experiment, $state, Status, TestInProgressService, host, $http) {

      $scope.cancel = false;

      $scope.$watch(function () {
        return Status.getData();
      }, function (data, oldData) {
        if (!data) return;
        if (!data.experimentController) return;
        if (!oldData) return;
        if (!oldData.experimentController) return;

        $scope.data = data;
        $scope.state = data.experimentController.machine.state;
        $scope.timeRemaining = TestInProgressService.timeRemaining(data);

        if ($scope.state !== 'Idle' && parseInt(data.experimentController.expriment.step.id) !== parseInt(oldData.experimentController.expriment.step.id)) {
          console.log(data.experimentController.expriment.step);
          console.log($scope.experiment);
        }

        if (data.experimentController.expriment && !$scope.experiment) {
          TestInProgressService.getExperiment(data.experimentController.expriment.id).then(function (exp) {
            $scope.experiment = exp;
          });
        }
        if ($scope.state === 'Paused' && $state.current.name === 'step-3') {
          $state.go('step-4');
          return;
        }
        if ($scope.state === 'Idle' && (oldData.experimentController.machine.state !== 'Idle' || $state.current.name === 'step-5')) {
          // experiment is complete
          $state.go('step-6');
          $http.put(host + '/settings', {settings: {"calibration_id": $scope.experiment.id}});
        }
      }, true);

      $scope.lidHeatPercentage = function () {
        if (!$scope.experiment) return 0;
        if (!$scope.data) return 0;
        return ($scope.data.lid.temperature/$scope.experiment.protocol.lid_temperature);
      };

      $scope.blockHeatPercentage = function () {
        var blockHeat = $scope.getBlockHeat();
        if (!blockHeat) return 0;
        if (!$scope.experiment) return 0;
        return ($scope.data.heatblock.temperature/blockHeat);
      };

      $scope.getBlockHeat = function () {
        if (!$scope.experiment) return;
        if (!$scope.experiment.protocol.stages[0]) return;
        if (!$scope.experiment.protocol.stages[0].stage.steps[0]) return;
        return $scope.experiment.protocol.stages[0].stage.steps[0].step.temperature;
      }

      $scope.createExperiment = function () {
        var exp = new Experiment({
          experiment: {guid: 'optical_cal'}
        });
        exp.$save().then(function (resp) {
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

    }
  ]);
})();