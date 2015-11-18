(function () {
  window.App.controller('OpticalCalibrationCtrl', [
    '$scope',
    '$window',
    'Experiment',
    '$state',
    'Status',
    'TestInProgressService',
    function OpticalCalibrationCtrl ($scope, $window, Experiment, $state, Status, TestInProgressService) {

      $scope.cancel = false;

      $scope.$watch(function () {
        return Status.getData();
      }, function (data) {
        console.log(data);
        if (!data) return;
        if (!data.experimentController) return;
        if (!data.experimentController.expriment) return;
        $scope.data = data;
        $scope.state = data.experimentController.machine.state;
        if ($scope.state === 'Paused' && $state.current.name !== 'step-3') {
          $state.go('step-4');
          return;
        }
        if (data.experimentController.expriment && !$scope.experiment) {
          TestInProgressService.getExperiment(data.experimentController.expriment.id).then(function (exp) {
            $scope.experiment = exp;
          });
        }
      });

      // function getSteps (experiment) {
      //   var steps = [];
      //   for (var i=0; i < experiment.protocol.stages.length;i++) {
      //     var stage = experiment.protocol.stages[i];
      //     var stage_steps = stage.stage.steps;

      //     for (var ii=0; ii < stage_steps.length; ii ++) {
      //       var step = stage_steps[i].step;
      //       step.id = parseInt(step.id);
      //       steps.push(step);
      //     }
      //   }
      //   console.log('steps:');
      //   console.log(steps);
      //   return steps;
      // }

      // function getCurrentStep (steps, step_id) {
      //   console.log('step_id: '+ step_id);
      //   step_id = parseInt(step_id);
      //   var s = _.find(steps, {id: step_id});
      //   console.log('currentStep:');
      //   console.log(s);
      //   return s;
      // }

      $scope.getBlockHeat = function () {
        if (!$scope.experiment) return;
        if (!$scope.experiment.protocol.stages[0]) return;
        if (!$scope.experiment.protocol.stages[0].stage.steps[0]) return;
        return $scope.experiment.protocol.stages[0].stage.steps[0].step.temperature;
        // if (!$scope.data) return;
        // if (!$scope.data.experimentController) return;
        // if (!$scope.data.experimentController.expriment) return;

        // var steps = getSteps($scope.experiment);
        // var currentStep = getCurrentStep(steps, $scope.data.experimentController.expriment.step.id);
        // return currentStep.temperature;
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
          $window.location.assign('/#/user/settings');
        });
      };

    }
  ]);
})();