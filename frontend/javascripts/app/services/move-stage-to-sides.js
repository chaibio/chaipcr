window.ChaiBioTech.ngApp.service('moveStageToSides', [
    function() {

        this.moveToSide = function(direction, draggedStage, targetStage) {

            if(this.validMove(direction, draggedStage, targetStage)) {

                var moveCount;
                if(direction === "left") {
                    moveCount = -30;
                    this.makeSurePreviousMovedLeft(draggedStage, targetStage);
                } else if("right") {
                    moveCount = 30;
                    this.makeSureNextMovedRight(draggedStage, targetStage);
                }
                this.moveToSideStageComponents(moveCount, targetStage);
                targetStage.stageMovedDirection = direction; // !important
                return "Valid Move";
            }
            return null;
      };

      this.validMove = function(direction, draggedStage, targetStage) {

        if(targetStage.stageMovedDirection === null) {

          if(direction === "left") {
            // For very first stage, It can't move further left.
            if(targetStage.previousStage === null) {
              if(draggedStage.index !== 0) {
                return false;
              }
            }
            // look if we have space at left;
            if(targetStage.previousStage && targetStage.left - (targetStage.previousStage.left + targetStage.previousStage.myWidth) < 10) {
              return false;
            }
            targetStage.stageMovedDirection = "left";

          } else if(direction === "right") {

            if(targetStage.nextStage === null) {
              
              if(targetStage.sourceStage === true) {
                //If we clicked on move-step, stage is sourceStage
                return true;
              }

              if(draggedStage.index === targetStage.parent.allStageViews.length) {
                // For the very first time, we need to move only if we dragged the very last stage.
                targetStage.stageMovedDirection = "right";
                return true;
              }
              return false;
            }
            // We move only if we have space in the right side.
            if(targetStage.nextStage && (targetStage.nextStage.left) - (targetStage.left + targetStage.myWidth) < 10) {
              return false;
            }
            targetStage.stageMovedDirection = "right";
          }
        } else if(targetStage.stageMovedDirection){ // if it has left or right value
          if(targetStage.stageMovedDirection === "left" && direction === "left") {
            return false;
          }
          if(targetStage.stageMovedDirection === "right" && direction === "right") {
            return false;
          }
        }

        return true;
      };

      this.makeSurePreviousMovedLeft = function(draggedStage, targetStage) {

        var stage = targetStage.previousStage;
        while(stage) {
          if(stage.stageMovedDirection !== "left") {
            console.log("Looking");
            this.moveToSide("left", draggedStage, stage);
          }
          stage = stage.previousStage;
        }
      };

      this.makeSureNextMovedRight = function(draggedStage, targetStage) {
        var stage = this.nextStage;
        while(stage) {
          if(stage.stageMovedDirection !== "right") {
            this.moveToSide("right", draggedStage, stage);
          }
          stage = stage.nextStage;
        }
      };

      this.moveToSideStageComponents = function(moveCount, targetStage) {
        
        targetStage.stageGroup.set({left: targetStage.left + moveCount }).setCoords();
        targetStage.dots.set({left: (targetStage.left + moveCount ) + 3}).setCoords();
        targetStage.left = targetStage.left + moveCount;
        var previousMovingFound = false;
        
        targetStage.childSteps.forEach(function(step, index) {
          step.moveStep(1, true);
          step.circle.moveCircleWithStep();
        });
        
        if(targetStage.sourceStage === true) {
            this.manageSourceStageStepMovement(moveCount, targetStage);
        }
      };

      this.manageSourceStageStepMovement = function(moveCount, targetStage) {

        targetStage.childSteps.some(function(step, index) {
            if(step.previousIsMoving) {
              var tempStep = step;
              while(tempStep) {
                tempStep.left = tempStep.left + 40;
                tempStep.moveStep(0, false);
                tempStep.circle.moveCircleWithStep();
                tempStep = tempStep.nextStep;
              }
              return true;
            }
          }, targetStage);

          if(targetStage.parent.moveDots.baseStep) {
            var baseStep = targetStage.parent.moveDots.baseStep;
            targetStage.parent.moveDots.setLeft(baseStep.left + baseStep.myWidth + 6).setCoords();
            return true;
          } else {
            targetStage.parent.moveDots.setLeft(targetStage.left + 6).setCoords();
          }         
      };

    }
]);
