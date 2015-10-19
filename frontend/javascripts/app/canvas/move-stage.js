window.ChaiBioTech.ngApp.factory('moveStageRect', [
  'ExperimentLoader',

  function(ExperimentLoader) {

    return {

      getMoveStepRect: function(me) {

        this.currentHit = 0;

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
          //stepText,
          me.imageobjects["drag-footer-image.png"],

        ],
          {
            originX: "left",
            originY: "top",
            width: 110,
            height:60,
            left: 38,
            top: 345,
            selectable: true,
            lockMovementY: true,
            hasControls: false,
            visible: false,
            hasBorders: false,
            name: "dragStageGroup"
          }
        );

      this.indicator.changeText = function(stageId, stepId) {

        var stageText = this.item(1);
        stageText.setText("MOVING STAGE " + (stageId + 1));

        //var stepText = this.item(2);
        //stepText.setText("STEP: " + (stepId + 1));

      };

      this.indicator.processMovement = function(stage, C) {

        var moveTarget = Math.floor((this.left + 60) / 120);
        var targetStep = C.allStepViews[moveTarget];
        var targetStage = targetStep.parentStage;

        if(stage.index !== targetStage.index && stage.index !== this.currentHit) {
          // Make a clone of the stage
          var stageClone = $.extend({}, stage.model), tempClosure = [];
          var stageStepsClone = $.extend([], stage.model.steps); // this is esential because array will change in the dletestep So keep the copy.

          tempClosure = stage.childSteps.map(function(step, index) {
            return step;
          });

          tempClosure.forEach(function(step, index) {
            step.parentStage.deleteStep({}, step);
          });

          stageClone.steps = stageStepsClone;
          var data = {
            stage: stageClone
          };

          C.addNewStage(data, targetStage);

          ExperimentLoader.moveStage(stageClone.id, targetStage.model.id)
            .then(function(data) {
              console.log("Moved", data);
            });

        } else { // we dont have to update so we update the move whiteFooterImage to old position.
          //this.setLeft(this.currentStep.left + 4);
        }

      };


      this.indicator.onTheMove = function(C) {

        var newIndex;
        C.allStepViews.some(function(step, index) {

          newIndex = step.parentStage.index;
          if(this.intersectsWithObject(step.hitPoint) && this.currentHit !== newIndex) {
              step.circle.manageClick();
              this.currentHit = newIndex;
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
