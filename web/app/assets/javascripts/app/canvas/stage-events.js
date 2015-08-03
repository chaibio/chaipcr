window.ChaiBioTech.ngApp.service('stageEvents',[
  function() {
    this.init = function($scope, canvas, C) {

      $scope.$watch('stage.num_cycles', function(newVal, oldVal) {

        var stage = $scope.fabricStep.parentStage;
        stage.cycleNo.setText(String(newVal));
        stage.cycleX.setLeft(stage.cycleNo.left + stage.cycleNo.width + 3);
        stage.cycles.setLeft(stage.cycleX.left + stage.cycleX.width);
        canvas.renderAll();
      });

      $scope.$watch('stage.auto_delta', function(newVal, oldVal) {
        // Actually we dont have to do anything in here
      });

      $scope.$watch('stage.auto_delta_start_cycle', function(newVal, oldVal) {
        // here too model is automatically updated
      });
    };
  }
]);
