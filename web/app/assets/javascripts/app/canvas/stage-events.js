window.ChaiBioTech.ngApp.service('stageEvents',[
  function() {
    this.init = function($scope, canvas) {

      $scope.$watch('stage.num_cycles', function(newVal, oldVal) {

        var stage = $scope.fabricStep.parentStage;
        stage.cycleNo.text = String(newVal);
        $scope.fabricStep.parentStage.cycleX.left = stage.cycleNo.left + stage.cycleNo.width + 3;
        stage.cycles.left = stage.cycleX.left + stage.cycleX.width;
        canvas.renderAll();
      });

      $scope.$watch('step.temperature', function(newVal, oldVal) {

        var circle = $scope.fabricStep.circle;
        circle.circleGroup.top = circle.getTop().top;
        circle.manageDrag(circle.circleGroup);
        circle.circleGroup.setCoords();
        canvas.renderAll();
      });

      $scope.$watch('step.ramp.rate', function(newVal, oldVal) {
        $scope.fabricStep.showHideRamp();
      });

      $scope.$watch('step.name', function(newVal, oldVal) {
        var step = $scope.fabricStep;
        step.stepName.text = (step.model.name).toUpperCase();
        canvas.renderAll();
      });
    };
  }
]);
