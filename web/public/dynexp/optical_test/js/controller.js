(function () {
  window.App.controller('AppController', [
    '$scope',
    '$window',
    'Experiment',
    '$state',
    '$stateParams',
    'Status',
    'TestInProgressService',
    'CONSTANTS',
    'Helper',
    function AppController ($scope, $window, Experiment, $state, $stateParams, Status, TestInProgressService, CONSTANTS, Helper) {

      $scope.cancel = false;
      $scope.CONSTANTS = CONSTANTS;
      $scope.isFinite = isFinite;
      $('.content').addClass('analyze');

      function getExperiment(exp_id, cb) {
        TestInProgressService.getExperiment(exp_id).then(function (exp) {
          $scope.experiment = exp;
          if(cb) cb(exp);
        });
      }

      $scope.loop = [];
      for (var i=0; i < 8; i ++) {
        $scope.loop.push(i);
      }

      $scope.$watch(function () {
        return Status.getData();
      }, function (data, oldData) {
        if (!data) return;
        if (!data.experiment_controller) return;
        if (!oldData) return;
        if (!oldData.experiment_controller) return;

        $scope.data = data;
        $scope.state = data.experiment_controller.machine.state;
        $scope.old_state = oldData.experiment_controller.machine.state;
        $scope.timeRemaining = TestInProgressService.timeRemaining(data);

        if (data.experiment_controller.expriment && !$scope.experiment) {
          getExperiment(data.experiment_controller.expriment.id);
        }

        if($scope.state === 'idle' && $scope.old_state !=='idle') {
          // exp complete
          $state.go('analyze', {id: $scope.experiment.id});
        }

        if ($state.current.name === 'analyze') Status.stopSync();

      }, true);


      $scope.analyzeExperiment = function () {
        $scope.analyzing = true
        if (!$scope.analyzedExp) {
          getExperiment($stateParams.id, function (exp) {
            if (exp.completion_status === 'success') {
              Experiment.getSteps($stateParams.id, [12, 13]).then(function (resp) {
                $scope.analyzedExp = Helper.getBaselineAndExcitation(resp.data.fluorescence_data);
                $scope.analyzing = false;
              });
            }
            else {
              $scope.analyzing = false;
            }
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
          experiment: {guid: 'optics_test'}
        });
        exp.$save().then(function (resp) {
          Experiment.startExperiment(resp.experiment.id).then(function () {
            $scope.experiment = resp.experiment;
            $state.go('exp-running');
          });
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
        var steps = TestInProgressService.getExperimentSteps($scope.experiment);
        return _.find(steps, {id: step_id});

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

      $scope.maxDeltaTm = function () {
        if (!$scope.tm_values) return 0;
        var max_delta_tm = TestInProgressService.getMaxDeltaTm($scope.tm_values);
        return max_delta_tm;
      };

      $scope.getResult = function (obj) {
        if(!obj) return false;
        return Helper.getResult(obj.baseline.fluorescence_value, obj.excitation.fluorescence_value);
      };

    }
  ]);
})();
