window.ChaiBioTech.ngApp.service('moveStepToSides', [
    function() {
        this.moveToSide = function(step, direction) {

            if(direction === "left" && step.stepMovedDirection !== "left") {
                step.left = step.left - 10;
                step.moveStep(0, false);
                step.circle.moveCircleWithStep();
                step.stepMovedDirection = "left";
                this.adjustDotsPlacingLeft(step);
            } else if(direction === "right" && step.stepMovedDirection !== "right") {
                
                step.left = step.left + 10;
                step.moveStep(0, false);
                step.circle.moveCircleWithStep();
                step.stepMovedDirection = "right";
                this.adjustDotsPlacingRight(step);
            }
      };

      this.adjustDotsPlacingRight = function(step) {

        if(step.nextIsMoving) {
            var C = step.parentStage.parent; 
            C.moveDots.setLeft(step.left + step.myWidth + 6);
            C.moveDots.setCoords();
            C.moveDots.setVisible(true);
        }
        
      };

      this.adjustDotsPlacingLeft = function(step) {

          if(step.nextIsMoving) {
            this.adjustDotsPlacingRight(step);
          }

        if(step.previousIsMoving) {
            if(step.previousStep) {
                var C = step.parentStage.parent; 
                C.moveDots.setLeft(step.previousStep.left + step.previousStep.myWidth + 6);
                C.moveDots.setCoords();
                C.moveDots.setVisible(true);
            }
        }
      };
    }
]);