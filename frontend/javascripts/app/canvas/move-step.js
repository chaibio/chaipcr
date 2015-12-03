window.ChaiBioTech.ngApp.factory('moveStepRect', [
  'ExperimentLoader',

  function(ExperimentLoader) {

    return {

      getMoveStepRect: function(me) {

        this.currentHit = 0;

        var smallCircle = new fabric.Circle({
          radius: 6,
          fill: '#FFB300',
          stroke: "black",
          strokeWidth: 3,
          selectable: false,
          left: 48,
          top: 298,
          originX: 'center', originY: 'center',
          //top: -2
        });

        var smallCircleTop = new fabric.Circle({
          radius: 5, fill: 'black', selectable: false, left: 48, top: 13, originX: 'center', originY: 'center',
        });

        var temperatureText = new fabric.Text(
          "20º", {
            fill: 'black',  fontSize: 20, selectable: false, originX: 'left', originY: 'top',
            top: 9, left: 12, fontFamily: "dinot-bold"
          }
        );

        var holdTimeText = new fabric.Text(
          "0:05", {
            fill: 'black',  fontSize: 20, selectable: false, originX: 'left', originY: 'top',
            top: 9, left: 50, fontFamily: "dinot"
          }
        );

        var indexText = new fabric.Text(
          "02", {
            fill: 'black',  fontSize: 16, selectable: false, originX: 'left', originY: 'top',
            top: 30, left: 17, fontFamily: "dinot-bold"
          }
        );

        var placeText= new fabric.Text(
          "01/01", {
            fill: 'black',  fontSize: 16, selectable: false, originX: 'left', originY: 'top',
            top: 30, left: 42, fontFamily: "dinot"
          }
        );

        var verticalLine = new fabric.Line([0, 0, 0, 276],{
          left: 47,
          top: 16,
          stroke: 'black',
          strokeWidth: 2,
          originX: 'left', originY: 'top',
        });

        var rect = new fabric.Rect({
          fill: 'white', width: 96, left: 0, height: 72, selectable: false, name: "step", me: this, rx: 1,
        });

        var coverRect = new fabric.Rect({
          fill: null, width: 96, left: 0, top: 0, height: 372, selectable: false, me: this, rx: 1,
        });

        me.imageobjects["drag-footer-image.png"].originX = "left";
        me.imageobjects["drag-footer-image.png"].originY = "top";
        me.imageobjects["drag-footer-image.png"].top = 52;
        me.imageobjects["drag-footer-image.png"].left = 9;

        indicator = new fabric.Group([
          rect,
          temperatureText,
          holdTimeText,
          indexText,
          placeText,
          me.imageobjects["drag-footer-image.png"],

        ],
          {
            originX: "left",
            originY: "top",
            left: 0,
            top: 298,
            height: 72,
            selectable: true,
            lockMovementY: true,
            hasControls: false,
            visible: true,
            hasBorders: false,
            name: "dragStepGroup"
          }
        );

        this.indicator = new fabric.Group([coverRect, indicator, verticalLine, smallCircle, smallCircleTop], {
          originX: "left",
          originY: "top",
          left: 38,
          top: 28,
          height: 372,
          width: 96,
          selectable: true,
          lockMovementY: true,
          hasControls: false,
          visible: true,
          hasBorders: false,
          name: "dragStepGroup"
        });
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

          ExperimentLoader.moveStep(stepClone.model.id, targetStep.model.id, targetStage.model.id)
            .then(function(data) {
              console.log("Moved", data);
            });

        } else { // we dont have to update so we update the move whiteFooterImage to old position.
          this.setLeft(this.currentStep.left + 4);
        }

      };


      this.indicator.onTheMove = function(C) {

        C.allStepViews.some(function(step, index) {

          if(this.intersectsWithObject(step.hitPoint) && this.currentHit !== index) {
              step.circle.manageClick();
              this.currentHit = index;
              return true;
          }
          return false;

        }, this);

      };

      return this.indicator;

      },

    };
  }
]
);
