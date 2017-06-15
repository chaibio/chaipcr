/*
 * Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
 * For more information visit http://www.chaibio.com
 *
 * Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

angular.module("canvasApp").factory('moveStepRect', [
  'ExperimentLoader',
  'previouslySelected',
  'circleManager',
  'StepPositionService',
  'moveStepIndicator',
  'verticalLineStepGroup',
  'StagePositionService',
  'movingStepGraphics',
  'StepMovementRightService',
  'StepMovementLeftService',
  function(ExperimentLoader, previouslySelected, circleManager, StepPositionService, moveStepIndicator, verticalLineStepGroup, StagePositionService,
  movingStepGraphics, StepMovementRightService, StepMovementLeftService) {

    return {

      getMoveStepRect: function(me) {
       
        // Things to do, Plan

        // more attention on showing right borders and hiding it.
        // make sure stages spread away, as move-step moves ..
        // == new algo 
        //1 When we move right, if we approch the black line by the half of the move-step-rect and if the step is last step of the stage
        // we need to shift the blck line to, before the first step of the next stage.
        // 2 make a list of void space , that is the space between spread out stages, and when we move half way across this
        // void space , shift the black line 
        // Make sure we can always reach source position. Implement leaving over it, even if its one step stage.

      this.indicator = new moveStepIndicator(me);
      this.indicator.verticalLine = new verticalLineStepGroup();
      
      this.indicator.init = function(step, footer, C) {
        this.tagSteps(step);
        step.parentStage.sourceStage = true;
        step.parentStage.stageHeader();
        
        if(step.parentStage.childSteps.length === 0) {
          step.parentStage.adjustHeader();
        }

        this.movement = null;
        this.currentLeft = null;
        this.movedStepIndex = null;
        this.currentMoveRight = null;
        this.rightOffset = 96;
        this.leftOffset = 0;
        this.kanvas = C;
        this.currentDropStage = step.parentStage;
        this.currentDrop = (step.previousStep) ? step.previousStep : "NOTHING";
        this.movedStageIndex = null;
        this.movedRightStageIndex = null;
        this.movedRightStageIndex = null;

        this.setVisible(true);
        this.verticalLine.setLeft(footer.left + 41);
        this.verticalLine.setVisible(true);
        C.canvas.bringToFront(this.verticalLine);
        this.setLeft(footer.left);
        this.startPosition = footer.left;
        this.changeText(step);
        StepPositionService.getPositionObject(this.kanvas.allStepViews);
        StagePositionService.getPositionObject();
        StagePositionService.getAllVoidSpaces();
      };

      this.indicator.tagSteps = function(step) {
        if(step.previousStep) {
          step.previousStep.nextIsMoving = true;
        } 
        if(step.nextStep) {
          step.nextStep.previousIsMoving = true;
        }
      };

      this.indicator.changeText = function(step) {

        this.temperatureText.setText(step.model.temperature + "º");
        //this.holdTimeText.setText(step.circle.holdTime.text);
        this.indexText.setText(step.numberingTextCurrent.text);
        this.placeText.setText(step.numberingTextCurrent.text + step.numberingTextTotal.text);
      };

      this.indicator.getDirection = function() {

        if(this.movement.left > this.currentLeft && this.direction !== "right") {
          this.direction = "right";
        } else if(this.movement.left < this.currentLeft && this.direction !== "left") {
          this.direction = "left";    
        }
        return this.direction;
      };

      
    
      

      this.indicator.movedRightAction = function() {

        this.currentMoveLeft = null; // Resetting
        this.currentDrop = this.kanvas.allStepViews[this.movedStepIndex];
        this.currentDropStage = this.currentDrop.parentStage;
        this.manageVerticalLineRight(this.movedStepIndex);
        this.manageBorderLeftForRight(this.movedStepIndex);
      }; 

      this.indicator.movedLeftAction = function() {

        this.currentMoveRight = null; // Resetting
        var step = this.kanvas.allStepViews[this.movedStepIndex];
        
        if(step.previousStep) {
          this.currentDrop = step.previousStep;
          this.currentDropStage = this.currentDrop.parentStage;
        } else {
          this.currentDrop = null;
          this.currentDropStage = step.parentStage;
        }
        
        this.manageVerticalLineLeft(this.movedStepIndex);
        this.manageBorderLeftForLeft(this.movedStepIndex);
      }; 

      this.indicator.shouldStageMoveLeft = function() {
        this.movedStageIndex = null;
        StagePositionService.allPositions.some(this.shouldStageMoveLeftCallback, this);
        return this.movedStageIndex;
      };

      this.indicator.shouldStageMoveLeftCallback = function(point, index) {
        if((this.movement.left + this.rightOffset) > point[2] && (this.movement.left + this.rightOffset) < point[2] + 150) {
          if(index !== this.movedLeftStageIndex) {
            this.movedStageIndex = this.movedLeftStageIndex = index;
            this.kanvas.allStageViews[index].moveToSide("left", {index: 10}); 
            // {index: 10} is sent so that the very first stage doesnt move, refer stage.validMove()
            // It dosnt have to be 10, can be any non zero value
            StagePositionService.getPositionObject();
            StagePositionService.getAllVoidSpaces();
            StepPositionService.getPositionObject(this.kanvas.allStepViews);
            return true;
          }
        }
      };

      this.indicator.shouldStageMoveRight = function() {
        this.movedStageIndex = null;
        StagePositionService.allPositions.some(this.shouldStageMoveRightCallback, this);
        return this.movedStageIndex;
      };

      this.indicator.shouldStageMoveRightCallback = function(point, index) {
        
        if((this.movement.left) > point[0] - 150 && (this.movement.left) < point[0]) {
          if(index !== this.movedRightStageIndex) {
            this.movedStageIndex = this.movedRightStageIndex = index;
            this.kanvas.allStageViews[index].moveToSide("right", this.currentDropStage);
            StagePositionService.getPositionObject();
            StagePositionService.getAllVoidSpaces();
            StepPositionService.getPositionObject(this.kanvas.allStepViews);
            return true;
          }
        }
      };

      this.indicator.onTheMove = function(C, movement) {

        this.setLeft(movement.left).setCoords();
        this.movement = movement;
        var direction = this.getDirection();
        this.currentLeft = movement.left;
        
        if(direction === 'right') {
          if(StepMovementRightService.ifOverRightSide(this) !== null) {
            this.movedRightAction();
          }
          if(this.shouldStageMoveLeft() !== null) {
            this.checkVoidSpaceLeft();
            this.movedRightStageIndex = null; // Resetting
            this.hideFirstStepBorderLeft();
          }
        } else if(direction === 'left') {
          if(StepMovementLeftService.ifOverLeftSide(this) !== null) {
            this.movedLeftAction();
          }
          if(this.shouldStageMoveRight() !== null) {
            this.checkVoidSpaceRight();
            this.movedLeftStageIndex = null; // Resetting
            this.hideFirstStepBorderLeft();
          }
        } 
      };

      this.indicator.checkVoidSpaceLeft = function() {
        StagePositionService.allVoidSpaces.some(this.voidSpaceCallbackLeft, this);
      };

      this.indicator.voidSpaceCallbackLeft = function(point, index) {
        var abPlace = this.movement.left + this.rightOffset;
        if(abPlace > point[0] && abPlace < point[1]) {
          this.verticalLineForVoidLeft(index);
          return true;
        }
      };

      this.indicator.verticalLineForVoidLeft = function(index) {

        var tStep = this.kanvas.allStageViews[index].childSteps[0];
        var place = this.kanvas.allStageViews[index].left - 5;
        
        if(tStep.previousIsMoving) {
          place = this.kanvas.moveDots.left + 7;
        }
        
        this.currentDrop = null;
        this.currentDropStage = this.kanvas.allStageViews[index]; // We need to insert the step as the first.
        this.verticalLine.setLeft(place);
        this.verticalLine.setCoords();
      };

      this.indicator.checkVoidSpaceRight = function() {
        StagePositionService.allVoidSpaces.some(this.voidSpaceCallbackRight, this);
      };

      this.indicator.voidSpaceCallbackRight = function(point, index) {
        var abPlace = this.movement.left;
        if(abPlace > point[0] && abPlace < point[1]) {
          this.verticalLineForVoidRight(index);
          return true;
        }
      };

      this.indicator.verticalLineForVoidRight = function(index) {
        
        if(this.kanvas.allStageViews[index - 1]) {
          var length = this.kanvas.allStageViews[index - 1].childSteps.length;
          var tStep = this.kanvas.allStageViews[index - 1].childSteps[length - 1];
          var place = this.kanvas.allStageViews[index - 1].left + this.kanvas.allStageViews[index - 1].myWidth - 5;
          
          if(tStep.nextIsMoving) {
            place = this.kanvas.moveDots.left + 7;
          }

          this.currentDrop = this.kanvas.allStageViews[index - 1].childSteps[length - 1];
          this.currentDropStage = this.kanvas.allStageViews[index - 1]; // We need to insert the step as the last.
          this.verticalLine.setLeft(place);
          this.verticalLine.setCoords();
        }
        
      };

      this.indicator.hideFirstStepBorderLeft = function() {

        if(this.kanvas.allStageViews[this.movedStageIndex].childSteps[0]) {
          this.kanvas.allStageViews[this.movedStageIndex].childSteps[0].borderLeft.setVisible(false);
        }
      };

      this.indicator.manageVerticalLineRight = function(index) {

        var place = (this.kanvas.allStepViews[index].left + this.kanvas.allStepViews[index].myWidth - 2);
        if(this.kanvas.allStepViews[index].nextIsMoving === true) {
          place = this.kanvas.moveDots.left + 7;
        }
        this.verticalLine.setLeft(place);
        this.verticalLine.setCoords();
      };

      this.indicator.manageVerticalLineLeft = function(index) {
        
        var place = (this.kanvas.allStepViews[index].left - 12);
        if(this.kanvas.allStepViews[index].previousIsMoving === true) {
          place = this.kanvas.moveDots.left + 7;
        }        
        this.verticalLine.setLeft(place);
        this.verticalLine.setCoords();
      };

      this.indicator.manageBorderLeftForLeft = function(index) {
        
        if(this.kanvas.allStepViews[index + 1]) {
          this.kanvas.allStepViews[index + 1].borderLeft.setVisible(false);
        }
        this.kanvas.allStepViews[index].borderLeft.setVisible(true);
      };

      this.indicator.manageBorderLeftForRight = function(index) {
        
        if(this.kanvas.allStepViews[index].nextStep) {
          this.kanvas.allStepViews[index + 1].borderLeft.setVisible(true);
        }
        
        if(this.kanvas.allStepViews[index].index === 0) {
          this.kanvas.allStepViews[index].borderLeft.setVisible(true);
        } else {
          this.kanvas.allStepViews[index].borderLeft.setVisible(false);
        }     
        
      };

      this.indicator.manageSingleStage = function(step) {
        
        var data = {};
        
        if(step.parentStage.childSteps.length === 0) { // Incase we sourced from a one step stage
          
          step.parentStage.deleteStageContents();
          
          if(this.currentDrop === "NOTHING") { // NOTHING imply that the we havent moved the step, its just a click and release;
            
            data = {
              stage: movingStepGraphics.backupStageModel
            };

            if(step.parentStage.previousStage) {
              this.kanvas.addNewStage(data, step.parentStage.previousStage, "move_stage_back_to_original");
            } else {
              this.kanvas.addNewStageAtBeginning({}, data);
            }
            
            return;
          }
        }
      };

      this.indicator.processMovement = function(step, C) {

        step.parentStage.sourceStage = false;
        this.verticalLine.setVisible(false);
        var data = {};
        this.manageSingleStage(step);
        
        var modelClone = $.extend({}, step.model);
        
        var targetStep = this.currentDrop;

        var targetStage = this.currentDropStage;

        data = {
          step: modelClone
        };

        this.kanvas.allStageViews[0].moveAllStepsAndStagesSpecial();
        
        if(targetStep && targetStep.left) {
          targetStage.addNewStep(data, targetStep);
        } else { // If its null or NOTHING
          targetStep = {
            model: {
              id: null
            }
          };
          targetStage.addNewStepAtTheBeginning(data);
        }
        console.log(targetStep, "TargetStep");

        ExperimentLoader.moveStep(modelClone.id, targetStep.model.id, targetStage.model.id)
          .then(function(data) {
            console.log("Moved", data);
          });
          
      };

      return this.indicator;

      },

    };
  }
]
);
