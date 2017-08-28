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

angular.module("canvasApp").factory('moveStageRect', [
  'ExperimentLoader',
  'stage',
  'stageGraphics',
  'StagePositionService',
  'verticalLine',
  'moveStageIndicator',
  'correctNumberingService',
  'addStageService',
  'moveStageToSides',
  function(ExperimentLoader, stageDude, stageGraphics, StagePositionService, verticalLine, 
  moveStageIndicator, correctNumberingService, addStageService, moveStageToSides) {

    return {
      
      getMoveStageRect: function(me) {

          this.indicator = new moveStageIndicator(me);
          this.indicator.verticalLine = new verticalLine();
          this.indicator.canvasContaining = $('.canvas-containing');
          // Rough Idea,
          // When edit stages is clicked, make a map for all stage positions and its cordinates , like [left, middle], [middle, right]
          // Split each stage into two equal areas on top
          // there is no beacon, or testing hit
          // Instead of hit, check if we are in either of these areas,
          // If we are in the right side and moving right we need to make space and put the vertical line over there,
          // If we are in the left side and moving left , we need to make stace before the stage and put the vertical line there,
          // Take care of the boundary conditions.
          // defrag the code , move graphics into other place.
        
          this.indicator.init = function(stage, C, movement) {
            
            this.setLeft(stage.left - 50);
            this.setVisible(true);
            this.setCoords();
            
            this.kanvas = C;
            this.movement = movement;
            
            this.kanvas.canvas.bringToFront(this);
            
            this.rightOffset = 85;
            this.leftOffset = -55;
            this.currentLeft = movement.left;
            this.draggedStage = stage;

            this.movedStageIndex = null;
            this.currentMoveRight = null;
            this.currentMoveLeft = null;
            this.currentDrop = null;
            this.direction = null;
            

            this.verticalLine.setLeft(stage.left + 5);
            this.verticalLine.setVisible(true);
            this.verticalLine.setCoords();
            
            this.kanvas.canvas.bringToFront(this.verticalLine);

            if(stage.previousStage) {
              this.currentDrop = stage.previousStage;
            }
            StagePositionService.getPositionObject();
          };

          this.indicator.changeText = function(stage) {
            
            this.stageName.setText(stage.stageCaption.text);
            this.stageType.setText(stage.model.stage_type.toUpperCase());
          };

          this.indicator.getDirection = function() {

            if(this.movement.left > this.currentLeft && this.direction !== "right") {
              this.direction = "right";
            } else if(this.movement.left < this.currentLeft && this.direction !== "left") {
              this.direction = "left";    
            }
            return this.direction;
          };
        
          this.indicator.ifOverRightSideForOneStepStage = function() {
            this.movedStageIndex = null;
            StagePositionService.allPositions.some(this.ifOverRightSideForOneStepStageCallback, this);
            return this.movedStageIndex;
          };

          this.indicator.ifOverRightSideForOneStepStageCallback = function(point, index) {
            if(this.kanvas.allStageViews[index].childSteps.length === 1) {
              if((this.movement.left + this.leftOffset) > point[1] && (this.movement.left + this.leftOffset) < point[2]) {
                if(index !== this.currentMoveRight) {
                  moveStageToSides.moveToSide("left", this.draggedStage, this.kanvas.allStageViews[index]);
                  this.currentMoveRight = this.movedStageIndex = index;
                  StagePositionService.getPositionObject();
                }
              }
              return true;
            }
          };

          this.indicator.ifOverLeftSideForOneStepStage = function(movement, C) {
            this.movedStageIndex = null;
            StagePositionService.allPositions.some(this.ifOverLeftSideForOneStepStageCallback, this);
            return this.movedStageIndex;
          };

          this.indicator.ifOverLeftSideForOneStepStageCallback = function(point, index) {
            
            if(this.kanvas.allStageViews[index].childSteps.length === 1) {
              
              if((this.movement.left + this.rightOffset) > point[0] && (this.movement.left + this.rightOffset) < point[1]) {
                
                if(index !== this.currentMoveLeft) {
                  moveStageToSides.moveToSide("right", this.draggedStage, this.kanvas.allStageViews[index]);
                  this.currentMoveLeft = this.movedStageIndex = index;
                  StagePositionService.getPositionObject();
                }
              }
              return true;
            }
          };

          this.indicator.ifOverRightSide = function() {
            this.movedStageIndex = null;
            StagePositionService.allPositions.some(this.ifOverRightSideCallback, this);
            return this.movedStageIndex;
          };

          this.indicator.ifOverRightSideCallback = function(points, index) {
            if((this.movement.left + this.rightOffset) > points[1] && (this.movement.left + this.rightOffset) < points[2]) {
              
              if(index !== this.currentMoveRight) {
                moveStageToSides.moveToSide("left", this.draggedStage, this.kanvas.allStageViews[index]);
                this.currentMoveRight = this.movedStageIndex = index;
                StagePositionService.getPositionObject();
              }
              return true;
            }
          };

          this.indicator.ifOverLeftSide = function() {
            this.movedStageIndex = null;
            StagePositionService.allPositions.some(this.ifOverLeftSideCallback, this);
            return this.movedStageIndex;
          };

          this.indicator.ifOverLeftSideCallback = function(points, index) {
            if((this.movement.left + this.leftOffset) > points[0] && (this.movement.left + this.leftOffset) < points[1]) {
              
              if(this.currentMoveLeft !== index) {
                moveStageToSides.moveToSide("right", this.draggedStage, this.kanvas.allStageViews[index]);
                this.currentMoveLeft = this.movedStageIndex = index;
                StagePositionService.getPositionObject();
              }
              return true;
            }
          };

          this.indicator.movedRightAction = function() {
            this.currentMoveLeft = null; // Resetting
            this.currentDrop = this.kanvas.allStageViews[this.movedStageIndex];
            this.manageVerticalLineRight(this.movedStageIndex);
          };

          this.indicator.movedLeftAction = function() {
            this.currentMoveRight = null; // Resetting
            this.currentDrop = this.kanvas.allStageViews[this.movedStageIndex - 1];
            this.manageVerticalLineLeft(this.movedStageIndex);
          };

          this.indicator.onTheMove = function(movement) {
            
            this.setLeft(movement.left - 50).setCoords();
            this.movement = movement;
            var direction = this.getDirection();
            this.currentLeft = this.movement.left;
            this.checkMovingOffScreen(direction);
            
            if(direction === 'right') {
              if(this.ifOverRightSide() !== null) {
                this.movedRightAction();
              } else if(this.ifOverRightSideForOneStepStage() !== null) {
                this.movedRightAction();
              }
            
            } else if(direction === 'left') {
              if(this.ifOverLeftSide() !== null) {
                this.movedLeftAction();
              } else if(this.ifOverLeftSideForOneStepStage() !== null) {
                this.movedLeftAction();
              }
            }         
          };
       
          this.indicator.checkMovingOffScreen = function(direction) {

            if(direction === "right") {

              if(this.movement.left - this.canvasContaining.scrollLeft() > 889) {
                this.canvasContaining.scrollLeft(this.movement.left - 889);
              }
            } else if (direction === "left") {

              var anchor = this.canvasContaining.scrollLeft();
              if(anchor > this.movement.left) {
                this.canvasContaining.scrollLeft((anchor - (anchor - this.movement.left)));
              }
            }
          };

          this.indicator.manageVerticalLineRight = function(index) {
            
            var place = (this.kanvas.allStageViews[index].left + this.kanvas.allStageViews[index].myWidth + 13);
            this.verticalLine.setLeft(place);
            this.verticalLine.setCoords();
          };

          this.indicator.manageVerticalLineLeft = function(index) {

            var place = (this.kanvas.allStageViews[index].left - 25);
            this.verticalLine.setLeft(place);
            this.verticalLine.setCoords();
          };

          this.indicator.processMovement = function(stage, circleManager) {

            this.applyMovement(stage, circleManager);
            console.log("Landed .... !: Dragged stage->", this.draggedStage.index);

            var pre_id = (this.currentDrop) ? this.currentDrop.model.id : null;
            ExperimentLoader.moveStage(stage.model.id, pre_id).then(function(dat) {
            }, function(err) {
              console.log(err);
            });

            this.hideElements();
            
        };

        this.indicator.hideElements = function() {

            this.setVisible(false);
            this.direction = null;
            this.verticalLine.setVisible(false);
        };
        
        this.indicator.applyMovement = function(stage_, circleManager) {
          // May be reuse the code in addStageService
          var model = this.draggedStage.model;
          var stageIndex = (this.currentDrop) ? this.currentDrop.index : 0;

          if(stageIndex === 0 && !this.currentDrop) { //if we insert into the very first place.
            addStageService.addNewStageAtBeginning({stage: model});
          } else {
            addStageService.addNewStage({stage: model}, this.currentDrop, "move_stage_back_to_original");
          }

        };

        return this.indicator;
      },
    };
  }
]);
