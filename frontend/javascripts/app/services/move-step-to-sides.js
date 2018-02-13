window.ChaiBioTech.ngApp.service('moveStepToSides', [
    function() {
        this.moveToSide = function(step, direction, mouseOver) {

            console.log(mouseOver);

            if(direction === "left" && step.stepMovedDirection !== "left") {    
                if(mouseOver.enterDirection === "left" && mouseOver.exitDirection === "right") {
                    //this.makeSurePreviousStepMovedLeft(step);
                    this.moveStepToLeft(step);
                }
                
            } 
            
            if(direction === "right" && step.stepMovedDirection !== "right") {
                if(mouseOver.enterDirection === "right" && mouseOver.exitDirection === "left") {
                    //this.makeSureNextStepMovedRight(step);
                    this.moveStepToRight(step);
                } 
            } 


            /*if(direction === "left" && step.stepMovedDirection !== "left") {
                
                if(step.previousStep && step.previousStep.stepMovedDirection === "left") {
                    step.left = step.left - 20;
                    step.moveStep(0, false);
                    step.circle.moveCircleWithStep();
                    step.stepMovedDirection = "left";
                    this.adjustDotsPlacingLeft(step);

                } else if(! step.previousStep) { // If step is the very first in the stage.
                    step.left = step.left - 20;
                    step.moveStep(0, false);
                    step.circle.moveCircleWithStep();
                    step.stepMovedDirection = "left";
                    this.adjustDotsPlacingLeft(step);
                }

                
            } else if(direction === "right" && step.stepMovedDirection !== "right") {

                if(step.nextStep && step.nextStep.stepMovedDirection === "right") {

                    step.left = step.left + 20;
                    step.moveStep(0, false);
                    step.circle.moveCircleWithStep();
                    step.stepMovedDirection = "right";
                    this.adjustDotsPlacingRight(step);
                } else if(! step.nextStep) { // if step is the last one in the stage.
                    step.left = step.left + 20;
                    step.moveStep(0, false);
                    step.circle.moveCircleWithStep();
                    step.stepMovedDirection = "right";
                    this.adjustDotsPlacingRight(step);
                }                
            }*/
      };

      this.makeSurePreviousStepMovedLeft = function(step) {

        var anchor = step.previousStep;
        while(anchor) {
            if(anchor.stepMovedDirection !== "left") {
                this.moveStepToLeft(anchor);
            }
            anchor = anchor.previousStep;
        }
      };

      this.makeSureNextStepMovedRight = function(step) {

        var anchor = step.nextStep;

        while(anchor) {
            if(anchor.stepMovedDirection !== "right") {
                this.moveStepToRight(anchor);   
            }
            anchor = anchor.nextStep;
        }
      };

      this.moveStepToRight = function(step) {
        step.left = step.left + 20;
        step.moveStep(0, false);
        step.circle.moveCircleWithStep();
        step.stepMovedDirection = "right";
        if(! step.previousStep) {
            this.manageStageBorder(step);
        }
        this.adjustDotsPlacingRight(step);
      };

      this.moveStepToLeft = function(step) {
        
        step.left = step.left - 20;
        step.moveStep(0, false);
        step.circle.moveCircleWithStep();
        step.stepMovedDirection = "left";
        
        if(! step.previousStep) {
            this.manageStageBorder(step);
        }
        this.adjustDotsPlacingLeft(step);
      };

      this.manageStageBorder = function(step) {

        var stage = step.parentStage;
        var border = stage.border;
        border.setLeft(step.left - 3);
        border.setCoords(); 
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