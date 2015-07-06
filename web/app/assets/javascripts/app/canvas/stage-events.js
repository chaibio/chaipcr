window.ChaiBioTech.ngApp.service('stageEvents',[
  function() {
    this.init = function($scope, canvas) {

      $scope.$watch('stage.num_cycles', function(val, oldVal) {
        
        var stage = $scope.fabricStep.parentStage;
        stage.cycleNo.text = String(val);
        $scope.fabricStep.parentStage.cycleX.left = stage.cycleNo.left + stage.cycleNo.width + 3;
        stage.cycles.left = stage.cycleX.left + stage.cycleX.width;
        canvas.renderAll();
      });


    };
  }
]);
