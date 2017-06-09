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
  function(ExperimentLoader, previouslySelected, circleManager, StepPositionService, moveStepIndicator, verticalLineStepGroup, StagePositionService,
  movingStepGraphics) {

    return {

      getMoveStepRect: function(me) {
       
        // Things to do, Plan

        // more attention on showing right borders and hiding it.
        // make sure stages spread away, as move-step moves ..
        
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

      this.indicator.ifOverRightSide = function() {
        this.movedStepIndex = null;

        StepPositionService.allPositions.some(this.ifOverRightSideCallback, this);
        return this.movedStepIndex;
      };

      this.indicator.ifOverRightSideCallback = function(points, index) {

        if((this.movement.left + this.rightOffset) > points[1] && (this.movement.left + this.rightOffset) < points[2]) {
              
          if(index !== this.currentMoveRight) {
            console.log("Found", index);
            this.kanvas.allStepViews[index].moveToSide("left");
            this.currentMoveRight = this.movedStepIndex = index;
            StepPositionService.getPositionObject(this.kanvas.allStepViews);
          }
          return true;
        }
      };
    
      this.indicator.ifOverLeftSide = function() {
        this.movedStepIndex = null;
        StepPositionService.allPositions.some(this.ifOverLeftSideCallback, this);
        return this.movedStepIndex;
      };

      this.indicator.ifOverLeftSideCallback = function(points, index) {

        if((this.movement.left + this.leftOffset) > points[0] && (this.movement.left + this.leftOffset) < points[1]) {
          
          if(this.currentMoveLeft !== index) {
            this.kanvas.allStepViews[index].moveToSide("right");
            this.currentMoveLeft = this.movedStepIndex = index;
            StepPositionService.getPositionObject(this.kanvas.allStepViews);
          }
          return true;
        }
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
        //this.currentDrop = (step.previousStep) ? step.previousStep
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
            this.kanvas.allStageViews[index].moveToSide("left", this.currentDropStage);
            StagePositionService.getPositionObject();
            StepPositionService.getPositionObject(this.kanvas.allStepViews);
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
            StepPositionService.getPositionObject(this.kanvas.allStepViews);
          }
        }
      };

      this.indicator.onTheMove = function(C, movement) {

        this.setLeft(movement.left).setCoords();
        this.movement = movement;
        var direction = this.getDirection();
        this.currentLeft = movement.left;
        
        if(direction === 'right') {
          if(this.ifOverRightSide() !== null) {
            this.movedRightAction();
          }
          if(this.shouldStageMoveLeft() !== null) {
            this.movedLeftStageIndex = null;
            this.hideFirstStepBorderLeft();
          }
        } else if(direction === 'left') {
          if(this.ifOverLeftSide() !== null) {
            this.movedLeftAction();
          }
          if(this.shouldStageMoveRight() !== null) {
            this.movedRightStageIndex = null;
            this.hideFirstStepBorderLeft();
          }
        } 
      };

      this.indicator.hideFirstStepBorderLeft = function() {
        console.log("Called", this.movedStageIndex);
        if(this.kanvas.allStageViews[this.movedStageIndex].childSteps[0]) {
          this.kanvas.allStageViews[this.movedStageIndex].childSteps[0].borderLeft.setVisible(false);
        }
      };

      this.indicator.manageVerticalLineRight = function(index) {

        var place = (this.kanvas.allStepViews[index].left + this.kanvas.allStepViews[index].myWidth - 2);
        if(this.kanvas.allStepViews[index].nextIsMoving === true) {
          place = place + 18;
        }
        this.verticalLine.setLeft(place);
        this.verticalLine.setCoords();
      };

      this.indicator.manageVerticalLineLeft = function(index) {
        
        var place = (this.kanvas.allStepViews[index].left - 12);
        if(this.kanvas.allStepViews[index].previousIsMoving === true) {
          place = place - 17;
        }        
        this.verticalLine.setLeft(place);
        this.verticalLine.setCoords();
      };

      this.indicator.manageBorderLeftForLeft = function(index) {
        console.log("ittt");
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
          
          if(this.currentDrop === "NOTHING") { // NOTHING imply that the we havent moved the step, its just a click an release;
            
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
        
        if(targetStep) {
          targetStage.addNewStep(data, targetStep);
        } else {
          targetStep = {
            model: {
              id: null
            }
          };
          targetStage.addNewStepAtTheBeginning(data);
        }
        
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
