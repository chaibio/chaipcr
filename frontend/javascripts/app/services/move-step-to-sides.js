window.ChaiBioTech.ngApp.service('moveStepToSides', [
    'moveStageToSides',
    function(moveStageToSides) {

        this.moveToSide = function(step, direction, mouseOver, moveStepObj) {

            /*if(step.parentStage.sourceStage) {
                this.moveToSideForSourceStage(step, direction, mouseOver);
                return;
            }*/

            if(step.previousIsMoving) {
                this.managePrevisousIsMoving(step, direction, mouseOver, moveStepObj);
                return;
            }

            if(step.nextIsMoving) {
                this.manageNextIsMoving(step, direction, mouseOver, moveStepObj);
                return;
            }

            if(direction === "left" && step.stepMovedDirection !== "left") {    
                if(mouseOver.enterDirection === "left" && mouseOver.exitDirection === "right") {
                    //this.makeSurePreviousStepMovedLeft(step);
                    this.moveStepToLeft(step);
                    moveStepObj.emptySpaceTracker = {
                        stageIndex: step.parentStage.index,
                        left: step.index,
                        right: (step.nextStep) ? step.nextStep.index : null
                    };
                    return;
                }
                
            } 
            
            if(direction === "right" && step.stepMovedDirection !== "right") {
                if(mouseOver.enterDirection === "right" && mouseOver.exitDirection === "left") {
                    //this.makeSureNextStepMovedRight(step);
                    this.moveStepToRight(step);
                    moveStepObj.emptySpaceTracker = {
                        stageIndex: step.parentStage.index,
                        left: (step.previousStep) ? step.previousStep.index : null,
                        right: step.index
                    };
                    return;
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

      this.manageNextIsMoving = function(step, direction, mouseOver, moveStepObj) {

        if(direction === "right" && step.stepMovedDirection !== "right") {
            if(mouseOver.enterDirection === "right" && mouseOver.exitDirection === "left") {
                
                if(moveStepObj.emptySpaceTracker.stageIndex === null) {
                    
                    var s = step;
                    
                    while(s) {
                        if(s.stepMovedDirection === "right")
                            break;
                        
                        this.moveStepToRight(s);
                        s = s.nextStep; 
                    }

                    moveStepObj.emptySpaceTracker = {
                        stageIndex: step.parentStage.index,
                        left: (step.previousStep) ? step.previousStep.index : null,
                        right: step.index
                    };
                } else if(moveStepObj.emptySpaceTracker.stageIndex) {
                    if(step.nextStep && moveStepObj.emptySpaceTracker.right !== step.index) {
                        if(step.stepMovedDirection !== "right")
                            this.moveStepToRight(step);
                        if(step.nextStep.stepMovedDirection !== "right")
                            this.moveStepToRight(step.nextStep);
                        
                        moveStepObj.emptySpaceTracker = {
                            stageIndex: step.parentStage.index,
                            left: (step.previousStep) ? step.previousStep.index : null,
                            right: step.index
                        };
                    }
                }
            }
        }
      };

      this.managePrevisousIsMoving = function(step, direction, mouseOver, moveStepObj) {

        if(direction === "left" && step.stepMovedDirection !== "left") {
            if(mouseOver.enterDirection === "left" && mouseOver.exitDirection === "right") {
                
                if(moveStepObj.emptySpaceTracker.stageIndex === null) {

                    var s = step.nextStep;
                    while(s) {
                        if(s.stepMovedDirection === "right")
                            break;
                        this.moveStepToRight(s);
                        s = s.nextStep; 
                    }
                    moveStepObj.emptySpaceTracker = {
                        stageIndex: step.parentStage.index,
                        left: step.index,
                        right: (step.nextStep) ? step.nextStep.index : null
                    };
                } else if(moveStepObj.emptySpaceTracker.stageIndex){
                    console.log(moveStepObj.emptySpaceTracker);
                    if(step.previousStep && moveStepObj.emptySpaceTracker.left !== step.index) {
                        if(step.stepMovedDirection !== "left")
                            this.moveStepToLeft(step);
                        if(step.previousStep.stepMovedDirection !== "left")
                            this.moveStepToLeft(step.previousStep);

                        moveStepObj.emptySpaceTracker = {
                            stageIndex: step.parentStage.index,
                            left: step.index,
                            right: (step.nextStep) ? step.nextStep.index : null
                        };
                            
                    }

                }
            }
        }
      };

      this.moveToSideForSourceStage = function(step, direction, mouseOver) {

        if(direction === "left" && step.stepMovedDirection !== "left") {    
            if(mouseOver.enterDirection === "left" && mouseOver.exitDirection === "right") {
                //this.makeSurePreviousStepMovedLeft(step);
                //this.moveStepToLeft(step);
                if(step.previousIsMoving) {
                    // Move next stages to sides;
                    if(step.parentStage.nextStage) {
                        //var stage = step.parentStage.nextStage;
                        //while(stage) {
                            //moveStageToSides.moveToSideStageComponents(30, step.parentStage.nextStage);
                            //stage = stage.nextStage;
                        //}
                        
                    }
                }

            }
            
        } 
        
        if(direction === "right" && step.stepMovedDirection !== "right") {
            if(mouseOver.enterDirection === "right" && mouseOver.exitDirection === "left") {
                
                //this.makeSureNextStepMovedRight(step);
                //this.moveStepToRight(step);
            } 
        } 

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