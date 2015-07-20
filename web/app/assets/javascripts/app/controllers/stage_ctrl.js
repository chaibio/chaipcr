window.ChaiBioTech.ngApp.controller('StageStepCtrl', [
  '$scope',
  'ExperimentLoader',
  'canvas',
  function($scope, ExperimentLoader, canvas) {

    var that = this;
    $scope.stage = {};
    $scope.step = {};

    $scope.initiate = function() {

      ExperimentLoader.getExperiment()
        .then(function(data) {
          $scope.protocol = data.experiment;
          $scope.stage = ExperimentLoader.loadFirstStages();
          $scope.step = ExperimentLoader.loadFirstStep();
          $scope.$emit('general-data-ready');
          canvas.init($scope);
        });
    };

    $scope.initiate();

    $scope.applyValuesFromOutSide = function(circle) {
      // when the event or function call is initiated from non anular part of the app ... !!
      $scope.$apply(function() {
        $scope.step = circle.parent.model;
        $scope.stage = circle.parent.parentStage.model;
        $scope.fabricStep = circle.parent;
      });
    };

    $scope.applyValues = function(circle) {

      $scope.step = circle.parent.model;
      $scope.stage = circle.parent.parentStage.model;
      $scope.fabricStep = circle.parent;
    };

  }
]);
