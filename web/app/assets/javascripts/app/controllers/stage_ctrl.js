window.ChaiBioTech.ngApp.controller('StageStepCtrl', [
  '$scope',
  'ExperimentLoader',
  'stage',
  function($scope, ExperimentLoader, stage) {

    var that = this;
    $scope.stage = {};

    $scope.$on('dataLoaded', function() {

      $scope.stage = ExperimentLoader.loadFirstStages();
      $scope.step = ExperimentLoader.loadFirstStep();
      stage.scope = $scope;
    });

    $scope.WOWaction = function(cool) {
      console.log(cool);
    };
  }
]);
