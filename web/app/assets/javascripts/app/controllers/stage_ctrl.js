window.ChaiBioTech.ngApp.controller('StageStepCtrl', [
  '$scope',
  'ExperimentLoader',
  'canvas',
  function($scope, ExperimentLoader, canvas) {

    var that = this;
    $scope.stage = {};
    $scope.step = {};

    $scope.initiate = function() {
      ExperimentLoader.getExperiment().then(function(data) {
        $scope.protocol = data.experiment;
        $scope.stage = ExperimentLoader.loadFirstStages();
        $scope.step = ExperimentLoader.loadFirstStep();
        canvas.init($scope);
      });
    };

    $scope.initiate();
    /*$scope.$on('dataLoaded', function() {

      $scope.stage = ExperimentLoader.loadFirstStages();
      $scope.step = ExperimentLoader.loadFirstStep();
      $scope.$emit('general-data-ready');
    });*/

  }
]);
