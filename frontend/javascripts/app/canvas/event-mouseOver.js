window.ChaiBioTech.ngApp.factory('mouseOver', [
  'ExperimentLoader',
  'previouslySelected',
  'previouslyHoverd',
  'scrollService',
  function(ExperimentLoader, previouslySelected, previouslyHoverd, scrollService) {

    this.init = function(C, $scope, that) {
      
      var me;
      this.canvas.on("mouse:over", function(evt) {

        if(! evt.target) return false;

        switch(evt.target.name) {

          case "stepGroup":
            me = evt.target.me;
            if(C.editStageStatus === false) {
              me.closeImage.setVisible(true);
              if(previouslyHoverd.step && previouslyHoverd.step.uniqueName !== me.uniqueName) {
                previouslyHoverd.step.closeImage.setVisible(false);
              }
              previouslyHoverd.step = me;
              C.canvas.renderAll();
            }
          break;

          case "deleteStepButton":
            that.canvas.hoverCursor = "pointer";
          break;

          case "moveStepImage":
            evt.target.setVisible(false);
            C.stageMoveIndicator.setVisible(false);
            me = evt.target.step;
            if(! that.infiniteStep(me)) {
              that.footerMouseOver(C.indicator, me, "step");
            }

          break;

        }
      });
    };
    return this;
  }
]);
