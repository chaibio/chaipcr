window.ChaiBioTech.ngApp.service('stepEvents',[
  'stageGraphics',
  'stepGraphics',
  function(stageGraphics, stepGraphics) {

    var that = this;
    this.changeDeltaText = function($scope) {

      var stage = $scope.fabricStep.parentStage;
      if(stage.model.stage_type === "cycling") {
        stage.childSteps.forEach(function(step, index) {
          stepGraphics.autoDeltaDetails.call(step);
        });
      }
    };

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
        if(step.model.name) {
          step.stepName.text = (step.model.name).charAt(0).toUpperCase() + (step.model.name).slice(1).toLowerCase();
        } else {
          step.stepName.text = "Step " + (step.index + 1);
          step.stepNameText =  "Step " + (step.index + 1);
        }

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

      $scope.$watch('step.delta_duration_s', function(newVal, oldVal) {
        that.changeDeltaText($scope);
        canvas.renderAll();
      });

      $scope.$watch('step.delta_temperature', function(newVal, oldVal) {
        that.changeDeltaText($scope);
        canvas.renderAll();
      });
    };
  }
]);
