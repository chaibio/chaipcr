window.ChaiBioTech.ngApp.factory('mouseUp', [
  'ExperimentLoader',
  'previouslySelected',
  'previouslyHoverd',
  'scrollService',
  function(ExperimentLoader, previouslySelected, previouslyHoverd, scrollService) {

    this.init = function(C, $scope, that) {

      this.canvas.on("mouse:up", function(evt) {

        if(that.mouseDown) {
          that.canvas.defaultCursor = "default";
          that.startDrag = 0;
          that.mouseDown = false;
          that.canvas.renderAll();
        } else {
          that.canvas.moveCursor = "move";
        }

        if(that.moveStepActive) {
          if(that.mouseDownPos === evt.e.clientX) {
            var indicate = evt.target;
            step = indicate.parent;
            C.stepIndicator.processMovement(step, C);
          }
          C.moveDots.setVisible(false);
          C.stepIndicator.setVisible(false);
          that.moveStepActive = false;
          C.canvas.renderAll();
        }

      });
    };
    return this;
  }
]);
