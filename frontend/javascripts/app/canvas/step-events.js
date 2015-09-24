window.ChaiBioTech.ngApp.service('stepEvents',[
  function() {
    this.init = function($scope, canvas, C) {

      $scope.$watch('step.temperature', function(newVal, oldVal) {

        var circle = $scope.fabricStep.circle;
        circle.circleGroup.top = circle.getTop().top;
        circle.manageDrag(circle.circleGroup);
        circle.circleGroup.setCoords();
        canvas.renderAll();
      });

      $scope.$watch('step.ramp.rate', function(newVal, oldVal) {

        $scope.fabricStep.showHideRamp();
        canvas.renderAll();
      });

      $scope.$watch('step.name', function(newVal, oldVal) {

        var step = $scope.fabricStep;
        step.stepName.text = (step.model.name) ? (step.model.name).toUpperCase() : step.stepNameText;
        canvas.renderAll();
      });

      $scope.$watch('step.hold_time', function(newVal, oldVal) {

        var circle = $scope.fabricStep.circle;
        circle.changeHoldTime();
        //Check the last step. See if the last step has zero and put infinity in that case.
        C.allCircles[C.allCircles.length - 1].doThingsForLast();
        canvas.renderAll();
      });

      $scope.$watch('step.collect_data', function(newVal, oldVal) {

        // things to happen wen step.collect_data changes;
        var circle = $scope.fabricStep.circle;
        circle.showHideGatherData(newVal);
        circle.parent.gatherDataDuringStep = newVal;
        canvas.renderAll();
      });

      $scope.$watch('step.ramp.collect_data', function(newVal, oldVal) {

        if( $scope.fabricStep.index !== 0 || $scope.fabricStep.parentStage.index !== 0) {
          //if its not the very first step
          var circle = $scope.fabricStep.circle;
          circle.gatherDataGroup.setVisible(newVal);
          circle.parent.gatherDataDuringRamp = newVal;
          canvas.renderAll();
        }
      });

      $scope.$watch('step.pause', function(newVal, oldVal) {
        //if(newVal) {
          console.log(newVal);
          var circle = $scope.fabricStep.circle;
          circle.controlPause(newVal);
          canvas.renderAll();
        //}
      });
    };
  }
]);
