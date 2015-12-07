window.ChaiBioTech.ngApp.factory('objectModified', [
  'ExperimentLoader',
  'previouslySelected',
  'previouslyHoverd',
  'scrollService',
  function(ExperimentLoader, previouslySelected, previouslyHoverd, scrollService) {

    this.init = function(C, $scope, that) {

      var me, step;
      /**************************************
          When the dragging of the object is finished
      ***************************************/
      this.canvas.on('object:modified', function(evt) {

        switch(evt.target.name) {

          case "controlCircleGroup":

            ExperimentLoader.changeTemperature($scope)
              .then(function(data) {
                console.log(data);
            });
          break;

          case "moveStep":

            var indicate = evt.target;
            step = indicate.parent;
            //step.commonFooterImage.setVisible(true);
            C.stepIndicator.endPosition = indicate.left;
            C.stepIndicator.processMovement(step, C);
            C.canvas.renderAll();
          break;

          /*case "dragStageGroup":

            var indicateStage = evt.target;
            step = indicateStage.currentStep;
            indicateStage.setVisible(false);
            indicateStage.endPosition = indicateStage.left;
            indicateStage.processMovement(step.parentStage, C);
            C.canvas.renderAll();
          break;*/
        }
      });
    };
    return this;
  }
]);
