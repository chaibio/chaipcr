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
  function(ExperimentLoader, previouslySelected, circleManager, StepPositionService, moveStepIndicator, verticalLineStepGroup, StagePositionService,
  movingStepGraphics, StepMovementRightService, StepMovementLeftService, StageMovementRightService, StageMovementLeftService,
  StepMoveVoidSpaceRightService, StepMoveVoidSpaceLeftService) {

    return {

      getMoveStepRect: function(me) {
       
      this.indicator = new moveStepIndicator(me);
      this.indicator.verticalLine = new verticalLineStepGroup();
      
      this.indicator.init = function(step, footer, C) {
        this.tagSteps(step);
        step.parentStage.sourceStage = true;
        step.parentStage.stageHeader();
        
        if(step.parentStage.childSteps.length === 0) {
          step.parentStage.adjustHeader();
        }

        this.movement = this.currentLeft = this.movedStepIndex = this.currentMoveRight = 
        this.movedStageIndex = this.movedRightStageIndex = this.movedRightStageIndex = null;

        
        this.rightOffset = 96;
        this.leftOffset = 0;
        this.kanvas = C;
        this.currentDropStage = step.parentStage;
        this.currentDrop = (step.previousStep) ? step.previousStep : "NOTHING";
        
        
        
        this.verticalLine.setLeft(footer.left + 41);
        this.verticalLine.setVisible(true).setCoords();
        
        C.canvas.bringToFront(this.verticalLine);
        
        this.setLeft(footer.left);
        this.setVisible(true);
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

      this.indicator.onTheMove = function(C, movement) {

        this.setLeft(movement.left).setCoords();
        this.movement = movement;
        var direction = this.getDirection();
        this.currentLeft = movement.left;
        
        if(direction === 'right') {
          if(StepMovementRightService.ifOverRightSide(this) !== null) {
            StepMovementRightService.movedRightAction(this);
          }
          if(StageMovementLeftService.shouldStageMoveLeft(this) !== null) {
            StepMoveVoidSpaceLeftService.checkVoidSpaceLeft(this);
            this.movedRightStageIndex = null; // Resetting
            this.hideFirstStepBorderLeft();
          }
        } else if(direction === 'left') {
          if(StepMovementLeftService.ifOverLeftSide(this) !== null) {
            StepMovementLeftService.movedLeftAction(this);
          }
          if(StageMovementRightService.shouldStageMoveRight(this) !== null) {
            StepMoveVoidSpaceRightService.checkVoidSpaceRight(this);
            this.movedLeftStageIndex = null; // Resetting
            this.hideFirstStepBorderLeft();
          }
        } 
      };

      this.indicator.hideFirstStepBorderLeft = function() {

        if(this.kanvas.allStageViews[this.movedStageIndex].childSteps[0]) {
          this.kanvas.allStageViews[this.movedStageIndex].childSteps[0].borderLeft.setVisible(false);
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
