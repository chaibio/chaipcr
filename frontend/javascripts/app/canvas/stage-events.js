window.ChaiBioTech.ngApp.service('stageEvents',[
  'stepGraphics',
  'stageGraphics',
  function(stepGraphics, stageGraphics) {

    var that = this;
    this.changeDeltaText = function($scope, C) {

      var stage = $scope.fabricStep.parentStage;
      if(stage.model.stage_type === "cycling" && ! stage.parent.editStageStatus) {
        stage.childSteps.forEach(function(step, index) {
          stepGraphics.autoDeltaDetails.call(step);
        });
      }
    };

    this.init = function($scope, canvas, C) {

      $scope.$watch('stage.num_cycles', function(newVal, oldVal) {

        var stage = $scope.fabricStep.parentStage;
        /*stage.cycleNo.setText(String(newVal));
        stage.cycleX.setLeft(stage.cycleNo.left + stage.cycleNo.width + 3);
        stage.cycles.setLeft(stage.cycleX.left + stage.cycleX.width);*/
        stageGraphics.stageHeader.call(stage);
        canvas.renderAll();
      });

      $scope.$watch('stage.auto_delta', function(newVal, oldVal) {

        that.changeDeltaText($scope);
        canvas.renderAll();
      });

      $scope.$watch('stage.auto_delta_start_cycle', function(newVal, oldVal) {

        that.changeDeltaText($scope, C);
        canvas.renderAll();
      });


    };
  }
]);
