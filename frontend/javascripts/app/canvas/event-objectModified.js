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

        if(evt.target) return false;

        switch(evt.target.name) {

          case "controlCircleGroup":

            me = evt.target.me;
            ExperimentLoader.changeTemperature($scope)
              .then(function(data) {
                console.log(data);
            });
          break;

          /*case "dragStepGroup":

            var indicate = evt.target;
            step = indicate.currentStep;
            indicate.setVisible(false);
            step.commonFooterImage.setVisible(true);
            indicate.endPosition = indicate.left;
            indicate.processMovement(step, C);
            C.canvas.renderAll();
          break;

          case "dragStageGroup":

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
