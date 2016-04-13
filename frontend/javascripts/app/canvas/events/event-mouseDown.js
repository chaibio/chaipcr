angular.module("canvasApp").factory('mouseDown', [
  'ExperimentLoader',
  'previouslySelected',
  'previouslyHoverd',
  'scrollService',
  'circleManager',
  'editMode',
  function(ExperimentLoader, previouslySelected, previouslyHoverd, scrollService, circleManager, editMode) {

    /**************************************
        what happens when click is happening in canvas.
        what we do is check if the click is up on some particular canvas element.
        and we send the changes to angular directives.
    ***************************************/

    this.init = function(C, $scope, that) {
      // that originally points to event. Refer event.js
      var me;
      this.canvas.on("mouse:down", function(evt) {

        if(! evt.target) {
          that.setSummaryMode();
          return false;
        }
        that.mouseDown = true;

        switch(evt.target.name)  {

          case "stepDataGroup":

            var click = evt.e, target = evt.target, stepDataGroupLeft = target.left - 46,
            getP = that.canvas.getPointer(evt.e);
            that.selectStep(target.parentCircle);

            var group = target.parentCircle.stepDataGroup;
            var items = group._objects;
            unHookGroup(group, items);
            if(getP.x > stepDataGroupLeft && getP.x < (stepDataGroupLeft + 45)) {
              editMode.tempActive = true;
              startEditing(target.parentCircle.temperature);
            } else {
              editMode.holdActive = true;
              startEditing(target.parentCircle.holdTime);
            }

          break;

          case "stepGroup":

            me = evt.target.me;
            that.selectStep(me.circle);

          break;

          case "controlCircleGroup":

            me = evt.target.me;
            that.selectStep(me);
            that.canvas.moveCursor = "ns-resize";
          break;

          case "moveStep":

            that.mouseDownPos = evt.e.clientX;
            C.stepIndicator.init(evt.target.parent);
            evt.target.parent.toggleComponents(false);
            that.moveStepActive = true;
            that.canvas.moveCursor = "move";
            C.stepIndicator.changePlacing(evt.target);
            C.stepIndicator.changeText(evt.target.parent);
            that.calculateMoveLimit("step");
            circleManager.togglePaths(false); //put it back later
            C.moveDots.setLeft(evt.target.parent.left + 16);
            evt.target.parent.shrinkStep();
            C.moveDots.setVisible(true);
            C.canvas.bringToFront(C.moveDots);
            C.canvas.bringToFront(C.stepIndicator);
            C.canvas.renderAll();

          break;

          case "moveStage":
            that.canvas.moveCursor = "move";

          break;

          case "deleteStepButton":

            me  = evt.target.me;
            that.selectStep(me.circle);
            ExperimentLoader.deleteStep($scope)
            .then(function(data) {
              console.log("deleted", data);
              me.parentStage.deleteStep({}, me);
              C.canvas.renderAll();
            });
          break;
        }

      });

      unHookGroup = function(group, items) {

        group._restoreObjectsState();
        C.canvas.remove(group);
        for(var i = 0; i < items.length; i++) {
          C.canvas.add(items[i]);
        }
        C.canvas.renderAll();
      };

      startEditing = function(textToBeEdited) {
        C.canvas.setActiveObject(textToBeEdited);
        textToBeEdited.enterEditing();
        textToBeEdited.selectAll();
      };

    };

    return this;
  }
]);
