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
  'StageMovementRightService',
  'StageMovementLeftService',
  'StepMoveVoidSpaceRightService',
  'StepMoveVoidSpaceLeftService',
  'addStageService',
  function(ExperimentLoader, previouslySelected, circleManager, StepPositionService, moveStepIndicator, verticalLineStepGroup, StagePositionService,
  movingStepGraphics, StepMovementRightService, StepMovementLeftService, StageMovementRightService, StageMovementLeftService,
  StepMoveVoidSpaceRightService, StepMoveVoidSpaceLeftService, addStageService) {

    return {

      getMoveStepRect: function(me) {
       
      this.indicator = new moveStepIndicator(me);
      this.indicator.verticalLine = new verticalLineStepGroup();
      
      this.indicator.init = function(step, footer, C, backupStageModel) {

        this.tagSteps(step);
        step.parentStage.sourceStage = true;
        step.parentStage.stageHeader();
        
        if(step.parentStage.childSteps.length === 0) {
          //step.parentStage.adjustHeader();
        }

        this.movement = this.movedStepIndex = this.currentMoveRight = this.currentMoveLeft =
        this.movedStageIndex = this.movedRightStageIndex = this.movedLeftStageIndex = null;

        this.currentLeft = footer.left;

        this.backupStageModel = backupStageModel;        
        this.rightOffset = 96;
        this.leftOffset = 0;
        this.kanvas = C;
        this.currentDropStage = step.parentStage;
        this.currentDrop = (step.previousStep) ? step.previousStep : "NOTHING";
        
        this.verticalLine.setLeft(C.moveDots.left + 7).setVisible(true).setCoords();
        C.canvas.bringToFront(this.verticalLine);
        this.setLeft(footer.left).setVisible(true);
        this.changeText(step);
        StepPositionService.getPositionObject(this.kanvas.allStepViews);
        StagePositionService.getPositionObject();
        StagePositionService.getAllVoidSpaces();
      };

      this.indicator.initForOneStepStage = function(step, footer, C, backupStageModel) {
        
        step.parentStage.stageHeader();
        
        this.movement = this.movedStepIndex = this.currentMoveRight = this.currentMoveLeft =
        this.movedStageIndex = this.movedRightStageIndex = this.movedLeftStageIndex = null;

        this.currentLeft = footer.left;

        this.backupStageModel = backupStageModel;        
        this.rightOffset = 96;
        this.leftOffset = 0;
        this.kanvas = C;
        this.currentDropStage = step.parentStage;
        this.currentDrop = (step.previousStep) ? step.previousStep : "NOTHING";
        
        this.verticalLine.setLeft(footer.left).setVisible(true).setCoords();
        C.canvas.bringToFront(this.verticalLine);
        this.setLeft(footer.left).setVisible(true);
        
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
        this.holdTimeText.setText(step.circle.holdTime.text);
        this.indexText.setText(step.numberingTextCurrent.text);
        this.placeText.setText(step.numberingTextCurrent.text + step.numberingTextTotal.text);
      };

      this.indicator.getDirection = function() {

        if(this.movement.left > this.currentLeft && this.direction !== "right") {
          this.direction = "right";
          this.updateLocationOnMoveRight();
        } else if(this.movement.left < this.currentLeft && this.direction !== "left") {
          this.direction = "left";
          this.updateLocationOnMoveLeft();    
        }
        return this.direction;
      };

      this.indicator.updateLocationOnMoveRight = function() {
        //this.movedStepIndex = this.currentMoveLeft;
        //StepMovementRightService.movedRightAction(this);
        this.movement.left = this.movement.left - 40;
        //this.manageMovingRight();

      };

      this.indicator.updateLocationOnMoveLeft = function() {
        //this.movedStepIndex = this.currentMoveRight;
        //StepMovementLeftService.movedLeftAction(this);
        this.movement.left = this.movement.left + 40;
        //this.manageMovingLeft();
      };
      
      this.indicator.onTheMove = function(movement) {

        this.setLeft(movement.left);
        this.setCoords();
        this.movement = movement;
        var direction = this.getDirection();
        this.currentLeft = movement.left;
        
        if(direction === 'right') {
          this.movedLeftStageIndex = this.currentDropStage.index - 1;
          this.manageMovingRight();
        } else if(direction === 'left') {
          this.movedRightStageIndex = this.currentDropStage.index + 1;
          this.manageMovingLeft();
        } 
      };

      // Manage the movement of the indicator right side.
      this.indicator.manageMovingRight = function() {

        if(StepMovementRightService.ifOverRightSide(this) !== null) {
          StepMovementRightService.movedRightAction(this);
        }

        if(StageMovementLeftService.shouldStageMoveLeft(this) !== null) {
          
          this.movedRightStageIndex = null; // Resetting
          this.hideFirstStepBorderLeft();
        }
        StepMoveVoidSpaceLeftService.checkVoidSpaceLeft(this);
      };

      // Manage the movement of the indicator left side.
      this.indicator.manageMovingLeft = function() {
        
        if(StepMovementLeftService.ifOverLeftSide(this) !== null) {
          StepMovementLeftService.movedLeftAction(this);
        }

        if(StageMovementRightService.shouldStageMoveRight(this) !== null) {
          this.movedLeftStageIndex = null; // Resetting
          this.hideFirstStepBorderLeft();
        }
        StepMoveVoidSpaceRightService.checkVoidSpaceRight(this);
      };

      this.indicator.hideFirstStepBorderLeft = function() {

        if(this.kanvas.allStageViews[this.movedStageIndex].childSteps[0]) {
          this.kanvas.allStageViews[this.movedStageIndex].childSteps[0].borderLeft.setVisible(false);
        }
      };

      /*
        if the parent stage has only one step and we haven't moved it [If its just a click] this method is invoked.
      */
      this.indicator.manageSingleStepStage = function(step) {
        
        if(step.parentStage.childSteps.length === 0) { // Incase we sourced from a one step stage
          step.parentStage.deleteStageContents();
          
          if(this.currentDrop === "NOTHING") { // NOTHING imply that the we havent moved the step, its just a click and release;
            
            var data = {
              stage: this.backupStageModel
            };
            
            if(step.parentStage.previousStage) {
              addStageService.addNewStage(data, step.parentStage.previousStage, "move_stage_back_to_original");
            } else {
              addStageService.addNewStageAtBeginning(data);
            }
            return true;
          }
        }
        return false;
      };

      this.indicator.processMovement = function(step, C) {
        
        this.verticalLine.setVisible(false);
        if(this.manageSingleStepStage(step) === true) {
          return true;
        }

        step.parentStage.sourceStage = false;
        var modelClone = angular.copy(step.model);
        var targetStep = (!this.currentDrop || this.currentDrop === "NOTHING") ? { model: { id: null } } : this.currentDrop;
        var targetStage = this.currentDropStage;
        
        var data = {
          step: modelClone
        };

        this.kanvas.allStageViews[0].moveAllStepsAndStages();

        targetStage.addNewStep(data, targetStep);
        
        ExperimentLoader.moveStep(step.model.id, targetStep.model.id, targetStage.model.id)
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
