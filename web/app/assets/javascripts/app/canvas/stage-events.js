window.ChaiBioTech.ngApp.service('stageEvents',[
  function() {
    this.init = function($scope, canvas, C) {

      $scope.$watch('stage.num_cycles', function(newVal, oldVal) {

        var stage = $scope.fabricStep.parentStage;
        stage.cycleNo.text = String(newVal);
        $scope.fabricStep.parentStage.cycleX.left = stage.cycleNo.left + stage.cycleNo.width + 3;
        stage.cycles.left = stage.cycleX.left + stage.cycleX.width;
        canvas.renderAll();
      });

      $scope.$watch('stage.auto_delta', function(newVal, oldVal) {
        // Actually we dont have to do anything in here
      });

      $scope.$watch('stage.auto_delta_start_cycle', function(newVal, oldVal) {
        // here too model is automatically updated
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

      $scope.$watch('step.hold_time', function(newVal, oldVal) {
        var circle = $scope.fabricStep.circle;
        circle.changeHoldTime();
        //Check the last step. See if the last step has zero and put infinity in that case.
        C.allCircles[C.allCircles.length - 1].doThingsForLast();
      });
    };
  }
]);
