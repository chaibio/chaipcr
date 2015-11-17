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
        if (!data) return;
        if (!data.experimentController) return;
        if (!data.experimentController.expriment) return;
        if (data.experimentController.expriment && !$scope.experiment) {
          TestInProgressService.getExperiment(data.experimentController.expriment.id).then(function (exp) {
            $scope.experiment = exp;
          });
        }
      });

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

      $scope.cancelExperiment = function () {
        Experiment.stopExperiment($scope.experiment_id).then(function () {
          $window.location.assign('/#/user/settings');
        });
      };

    }
  ]);
})();