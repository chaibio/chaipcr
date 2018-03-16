window.ChaiBioTech.ngApp.service('moveStepToSides', [
    'moveStageToSides',
    function(moveStageToSides) {

        this.moveToSide = function(step, direction, mouseOver, moveStepObj) {
            console.log(step.ordealStatus);
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
                    this.emptySpaceTrackerLeft(step, moveStepObj);

                    if(step.previousStep === null) {
                        console.log("Okay I entered here ......");
                        moveStepObj.increaseHeaderLengthLeft(step.parentStage.index);
                    }
                    
                    return;
                }
                
            }
            
            if(direction === "right" && step.stepMovedDirection !== "right") {
                if(mouseOver.enterDirection === "right" && mouseOver.exitDirection === "left") {
                    //this.makeSureNextStepMovedRight(step);
                    this.moveStepToRight(step);
                    this.emptySpaceTrackerRight(step, moveStepObj);

                    if(step.nextStep === null) {
                        moveStepObj.increaseHeaderLengthRight(step.parentStage.index);
                    }

                    /*if(step.nextStep === null) {
                        if(step.parentStage.nextStage) {
                            var tStep = step.parentStage.nextStage.childSteps[0];
                            if(tStep.previousIsMoving && tStep.stepMovedDirection === "left") {
                                console.log("OyO");
                                this.moveStepToRight(tStep);
                            }
                            
                        }
                    }*/

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

      this.emptySpaceTrackerRight = function(step, moveStepObj) {

        moveStepObj.emptySpaceTracker = {
            stageIndex: step.parentStage.index,
            left: (step.previousStep) ? step.previousStep.index : null,
            right: step.index
        };
      };

      this.emptySpaceTrackerLeft = function(step, moveStepObj) {

        moveStepObj.emptySpaceTracker = {
            stageIndex: step.parentStage.index,
            left: step.index,
            right: (step.nextStep) ? step.nextStep.index : null
        };
      };

      this.manageNextIsMoving = function(step, direction, mouseOver, moveStepObj) {

        console.log("In manageNextIsMoving", step);

        if(direction === "right" && step.stepMovedDirection !== "right") {
            if(mouseOver.enterDirection === "right" && mouseOver.exitDirection === "left") {
                
                if(moveStepObj.emptySpaceTracker.stageIndex === null) {
                    console.log("stageIndex null -> right");
                    var s = step;
                    
                    while(s) {
                        if(s.stepMovedDirection === "right")
                            break;
                        
                        this.moveStepToRight(s);
                        s = s.nextStep; 
                    }

                    this.emptySpaceTrackerRight(step, moveStepObj);

                } else if(moveStepObj.emptySpaceTracker.stageIndex !== null) {
                    console.log("stageIndex -> right");
                    if(step.nextStep && moveStepObj.emptySpaceTracker.right !== step.index) {
                        if(step.stepMovedDirection !== "right")
                            this.moveStepToRight(step);
                        if(step.nextStep.stepMovedDirection !== "right")
                            this.moveStepToRight(step.nextStep);
                        
                        this.emptySpaceTrackerRight(step, moveStepObj);
                    } else if(! step.nextStep && step.nextIsMoving === true) {
                        
                        this.moveStepToRight(step);
                        this.emptySpaceTrackerRight(step, moveStepObj);
                        moveStepObj.increaseHeaderLengthRight(step.parentStage.index);
                    }
                }
            }
        } else if(direction === "right" && step.stepMovedDirection === "right") {
            if(mouseOver.enterDirection === "right" && mouseOver.exitDirection === "left") {
                if(step.nextStep === null && moveStepObj.emptySpaceTracker.right !== step.index) { // for the last step in the stage
                    this.moveStepToRight(step);
                    this.emptySpaceTrackerRight(step, moveStepObj);
                    moveStepObj.increaseHeaderLengthRight(step.parentStage.index); // incase header  is not extended due to fast movement.                    
                }
            }
        }
      };

      this.managePrevisousIsMoving = function(step, direction, mouseOver, moveStepObj) {
        console.log("In previousIsMoving", direction, step.stepMovedDirection);
        if(direction === "left" && step.stepMovedDirection !== "left") {
            if(mouseOver.enterDirection === "left" && mouseOver.exitDirection === "right") {
                console.log(moveStepObj.emptySpaceTracker, "This is ");
                if(moveStepObj.emptySpaceTracker.stageIndex === null) {
                    console.log("no stageIndex");
                    var s = step.nextStep;
                    while(s) {
                        if(s.stepMovedDirection === "right")
                            break;
                        this.moveStepToRight(s);
                        s = s.nextStep; 
                    }
                    this.emptySpaceTrackerLeft(step, moveStepObj);
                } else if(moveStepObj.emptySpaceTracker.stageIndex !== null) {
                    console.log("stageIndex");
                    if(step.previousStep && moveStepObj.emptySpaceTracker.left !== step.index) {
                        if(step.stepMovedDirection !== "left")
                            this.moveStepToLeft(step);
                        if(step.previousStep.stepMovedDirection !== "left")
                            this.moveStepToLeft(step.previousStep);

                        this.emptySpaceTrackerLeft(step, moveStepObj);
                            
                    } else if(step.previousStep === null && step.previousIsMoving === true) {

                        console.log("Wow ###############################");
                        this.moveStepToLeft(step);
                        this.emptySpaceTrackerLeft(step, moveStepObj);
                    } else if(step.previousStep === null) {
                        console.log("This segment", step);
                        //if(step.stepMovedDirection === "right") {
                        this.moveStepToLeft(step);
                        this.emptySpaceTrackerLeft(step, moveStepObj);
                        moveStepObj.increaseHeaderLengthLeft(step.parentStage.index);
                        //}
                    }

                }
            }
        } else if(direction === "left" && step.stepMovedDirection === "left") { // This is specifically done for for the first step of the stage.
            console.log(mouseOver.enterDirection, mouseOver.exitDirection);
            if(mouseOver.enterDirection === "left" && mouseOver.exitDirection === "right") {
                
                if(step.previousStep === null && moveStepObj.emptySpaceTracker.left !== step.index && step.parentStage.index === moveStepObj.emptySpaceTracker.stageIndex) { // When its the first step
                    console.log(moveStepObj.emptySpaceTracker.left, step.index, step.parentStage.index);
                    console.log("This is a interesting place", step.stepMovedDirection);
                    
                    this.moveStepToLeft(step);
                    this.emptySpaceTrackerLeft(step, moveStepObj);
                    moveStepObj.increaseHeaderLengthLeft(step.parentStage.index);
                } else {
                    console.log("Exceptional case", moveStepObj.emptySpaceTracker.left, step.index, step.parentStage.index, moveStepObj.emptySpaceTracker.stageIndex);
                    console.log(step.stepMovedDirection);
                    //this.moveStepToLeft(step);
                    //this.emptySpaceTrackerLeft(step, moveStepObj);
                    //moveStepObj.increaseHeaderLengthLeft(step.parentStage.index);
                }
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

        if(step.previousIsMoving) {
            var stage_ = step.parentStage;
            var border_ = stage_.border;
            border_.setLeft(stage_.left - 2);
            border_.setCoords(); 
            return;
        }
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
            } else if(! step.previousStep) {
                console.log("Wow +++++++++++++++++++");
                var can = step.parentStage.parent;
                can.moveDots.setLeft(step.left - 24);
                can.moveDots.setCoords();
                can.moveDots.setVisible(true);
            }
        }
      };
    }
]);