window.ChaiBioTech.ngApp.factory('moveStepRect', [
  'ExperimentLoader',

  function(ExperimentLoader) {

    return {

      getMoveStepRect: function(me) {

        var smallCircle = new fabric.Circle({
          radius: 4,
          fill: 'black',
          selectable: false,
          left: 63,
          top: 259,
          //top: -2
        });

        var stageText = new fabric.Text(
          "MOVING STAGE 2", {
            fill: 'black',  fontSize: 10, selectable: false, originX: 'left', originY: 'top',
            top: 12, left: 10, fontFamily: "Open Sans", fontWeight: "bold"
          }
        );

        var stepText = new fabric.Text(
          "STEP: 2", {
            fill: 'black',  fontSize: 10, selectable: false, originX: 'left', originY: 'top',
            top: 25, left: 10, fontFamily: "Open Sans", fontWeight: "bold"
          }
        );

        var verticalLine = new fabric.Line([0, 0, 0, 263],{
          left: 66,
          top: -2,
          stroke: 'black',
          strokeWidth: 2
        });

        var rect = new fabric.Rect({
          fill: 'white', width: 110, left: 5, height: 60, selectable: false, name: "step", me: this, rx: 3,
        });

        me.imageobjects["drag-footer-image.png"].top = 38;
        me.imageobjects["drag-footer-image.png"].left = 5;
        me.imageobjects["drag-footer-image.png"].originX = "left";
        me.imageobjects["drag-footer-image.png"].originY = "top";
        this.indicator = new fabric.Group([
          //verticalLine,

          rect,
          //smallCircle,
          stageText,
          stepText,
          me.imageobjects["drag-footer-image.png"],

        ],
          {
            originX: "left",
            originY: "top",
            width: 110,
            height:60,
            left: 38,
            top: 324,
            selectable: true,
            lockMovementY: true,
            hasControls: false,
            visible: false,
            hasBorders: false,
            name: "dragStepGroup"
          }
        );

      this.indicator.changeText = function(stageId, stepId) {

        var stageText = this.item(1);
        stageText.setText("MOVING STAGE " + (stageId + 1));

        var stepText = this.item(2);
        stepText.setText("STEP: " + (stepId + 1));

      };

      this.indicator.processMovement = function(step, C) {

        // Make a clone of the step
        var stepClone = $.extend({}, step);

        if(Math.abs(this.startPosition - this.endPosition) > 65) {

          // Find the place where you left the moved step
          var moveTarget = Math.floor((this.left + 60) / 120);
          var targetStep = C.allStepViews[moveTarget];
          var targetStage = C.allStepViews[moveTarget].parentStage;

          // Delete the step you moved
          step.parentStage.deleteStep({}, step);
          // add clone at the place
          var data = {
            step: stepClone.model
          };

          targetStage.addNewStep(data, targetStep);

          ExperimentLoader.moveStep(stepClone.model.id, targetStep.model.id)
            .then(function(data) {
              console.log("Moved", data);
            });

        } else { // we dont have to update so we update the move whiteFooterImage to old position.
          this.setLeft(this.currentStep.left + 4);
        }

      };


      this.indicator.onTheMove = function(movingObject, C) {

        // 1)create a point or a small rectangle at the farthest end of each steps
        // 2)hit test agaist it
        // May be group the common footer image with the look in the nicks design.
        // Nicks design image is going to be the background.
        // Change the background in the beginning of the scroll
        var length = C.allStepViews.length;

        for(var run = 0; run < length; run ++) {
          console.log("moving");
          if(movingObject.intersectsWithObject(C.allStepViews[run].hitPoint)) {
            console.log(run, "Hit", length);
            // Make the Jump;
            // use the previou to store the
            return false;
          }
        }
      };

      return this.indicator;

      },

    };
  }
]
);
