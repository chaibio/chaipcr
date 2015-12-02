(function () {
  window.App.controller('AppController', [
    '$scope',
    '$window',
    'Experiment',
    '$state',
    'Status',
    'TestInProgressService',
    'host',
    '$http',
    function AppController ($scope, $window, Experiment, $state, Status, TestInProgressService, host, $http) {

      $scope.cancel = false;
      $scope.loop = [];

      for (var i=0; i < 16; i ++) {
        $scope.loop.push(i);
      }

      $scope.$watch(function () {
        return Status.getData();
      }, function (data, oldData) {
        if (!data) return;
        if (!data.experimentController) return;
        if (!oldData) return;
        if (!oldData.experimentController) return;

        $scope.data = data;
        $scope.state = data.experimentController.machine.state;
        $scope.old_state = oldData.experimentController.machine.state;
        $scope.timeRemaining = TestInProgressService.timeRemaining(data);

        if (data.experimentController.expriment && !$scope.experiment) {
          TestInProgressService.getExperiment(data.experimentController.expriment.id).then(function (exp) {
            $scope.experiment = exp;
          });
        }

        if($scope.state === 'Idle' && $scope.old_state !=='Idle') {
          // exp complete
          $state.go('analyze');
          Status.stopSync();
        }

      }, true);


      $scope.analyzeExperiment = function () {
        if (!$scope.analyzedExp) {
          Experiment.analyze($scope.experiment.id).then(function (resp) {
            $scope.analyzedExp = resp.data;
          });
        }
      };

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
        if (!$scope.currentStep()) return;
        return $scope.currentStep().temperature;
      }

      $scope.createExperiment = function () {
        var exp = new Experiment({
          experiment: {guid: 'hrm_calibration'}
        });
        exp.$save().then(function (resp) {
          Experiment.startExperiment(resp.experiment.id).then(function () {
            $scope.experiment = resp.experiment;
            $state.go('exp-running');
          });
        });
      };

      // $scope.resumeExperiment = function () {
      //   Experiment.resumeExperiment().then(function () {
      //     $state.go('step-5');
      //   });
      // };

      $scope.cancelExperiment = function () {
        Experiment.stopExperiment($scope.experiment_id).then(function () {
          var redirect = '/#/user/settings';
          $window.location = redirect;
        });
      };

      $scope.isCollectingData = function () {
        if (!$scope.data) return false;
        if (!$scope.data.optics) return false;
        return ($scope.data.optics.collectData === 'true');
      };

      $scope.currentStep = function () {
        if (!$scope.experiment) return;
        if (!$scope.data) return;
        if (!$scope.data.experimentController) return;
        if (!$scope.data.experimentController.expriment) return;
        var step_id = parseInt($scope.data.experimentController.expriment.step.id);
        if (!step_id) return;
        var steps = TestInProgressService.getExperimentSteps($scope.experiment);
        return _.find(steps, {id: step_id});

      };

      $scope.finalStepHoldTime = function () {
        if (!$scope.experiment) return 0;
        if (!$scope.data) return 0;
        if (!$scope.data.experimentController) return 0;
        if (!$scope.data.experimentController.expriment) return 0;

        var step_id = parseInt($scope.data.experimentController.expriment.step.id);
        var steps = $scope.experiment.protocol.stages[0].stage.steps;
        return steps[steps.length-1].step.hold_time;

      };

    }
  ]);
})();