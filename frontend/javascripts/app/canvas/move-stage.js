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
  function(ExperimentLoader, stageDude, stageGraphics, StagePositionService, verticalLine) {

    return {
      
      getMoveStageRect: function(me) {

        this.currentDrop = null;
        this.startPosition = 0;
        this.endPosition = 0;
        this.currentLeft = 0;
        this.direction = null;

        var stageName = new fabric.Text(
          "STAGE 2", {
            fill: 'black',  fontSize: 12, selectable: false, originX: 'left', originY: 'top',
            top: 15, left: 35, fontFamily: "dinot-bold"
          }
        );

        var stageType = new fabric.Text(
          "HOLDING", {
            fill: 'black',  fontSize: 12, selectable: false, originX: 'left', originY: 'top',
            top: 30, left: 35, fontFamily: "dinot-regular"
          }
        );
        
        var rect = new fabric.Rect({
          fill: 'white', width: 135, left: 0, height: 58, selectable: false, name: "step", me: this, rx: 1,
        });

        var coverRect = new fabric.Rect({
          fill: null, width: 135, left: 0, top: 0, height: 372, selectable: false, me: this, rx: 1,
        });

        me.imageobjects["drag-stage-image.png"].originX = "left";
        me.imageobjects["drag-stage-image.png"].originY = "top";
        me.imageobjects["drag-stage-image.png"].top = 15;
        me.imageobjects["drag-stage-image.png"].left = 14;

        var indicatorRectangle = new fabric.Group([
          rect, stageName, stageType,
          me.imageobjects["drag-stage-image.png"],
        ],
          {
            originX: "left", originY: "top", left: 0, top: 0, height: 72, selectable: true, lockMovementY: true, hasControls: false,
            visible: true, hasBorders: false, name: "dragStageRect"
          }
        );

        this.indicator = new fabric.Group([coverRect, indicatorRectangle], {
          originX: "left", originY: "top", left: 38, top: 0, height: 372, width: 135, selectable: true,
          lockMovementY: true, hasControls: false, visible: false, hasBorders: false, name: "dragStageGroup"
        });

        this.indicator.verticalLine = new verticalLine();

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
          // rework on this part for smaller space...
          this.setLeft(stage.left - 50).setCoords();
          C.canvas.bringToFront(this);
          this.setVisible(true);
          this.rightOffset = 85;
          this.leftOffset = -60;
          this.currentLeft = movement.left;
          this.canvasContaining = $('.canvas-containing');
          this.currentMoveRight = null;
          this.currentMoveLeft = null;
          this.currentDrop = null;

          C.canvas.bringToFront(this.verticalLine);
          this.verticalLine.setLeft(stage.left + 5).setCoords();

          this.verticalLine.setVisible(true);
          C.canvas.bringToFront(this.verticalLine);

          this.draggedStage = stage;

          if(stage.previousStage) {
            this.currentDrop = stage.previousStage;
          }
          StagePositionService.getPositionObject(C.allStageViews);

        };

        this.indicator.changeText = function(stage) {

          stageName.setText(stage.stageCaption.text);
          stageType.setText(stage.model.stage_type.toUpperCase());
        };

        this.indicator.getDirection = function(movement) {

          if(movement.left > this.currentLeft && this.direction !== "right") {
            this.direction = "right";
          } else if(movement.left < this.currentLeft && this.direction !== "left") {
            this.direction = "left";    
          }
          return this.direction;
        };
        
        this.indicator.ifOverRightSide = function(movement, C) {
          var movedStageIndex = null;
           StagePositionService.allPositions.some(function(points, index) {
              if((movement.left + this.rightOffset) > points[1] && (movement.left + this.rightOffset) < points[2]) {
                
                if(index !== this.currentMoveRight) {
                  C.allStageViews[index].moveToSide("left", this.draggedStage);
                  this.currentMoveRight = movedStageIndex = index;
                }
                return true;
              }
            }, this);
            return movedStageIndex;
        };

        this.indicator.ifOverLeftSide = function(movement, C) {
          var movedStageIndex = null;
          StagePositionService.allPositions.some(function(points, index) {
              if((movement.left + this.leftOffset) > points[0] && (movement.left + this.leftOffset) < points[1]) {
                
                if(this.currentMoveLeft !== index) {
                  C.allStageViews[index].moveToSide("right", this.draggedStage);
                  this.currentMoveLeft = movedStageIndex = index;
                }
                return true;
              }
            }, this);
            return movedStageIndex;
        };

        this.indicator.onTheMove = function(C, movement) {
          
          this.setLeft(movement.left - 50).setCoords();
          var direction = this.getDirection(movement);
          this.currentLeft = movement.left;
          this.checkMovingOffScreen(C, movement, this.direction);
          
          if(direction === 'right') {
           var stageMovedRightIndex = this.ifOverRightSide(movement, C);
           if(stageMovedRightIndex !== null) {
            this.currentMoveLeft = null; // Resetting
            this.currentDrop = C.allStageViews[stageMovedRightIndex];
            this.manageVerticalLineRight(C, stageMovedRightIndex);
           }
           
          } else if(direction === 'left') {
            var stageMovedLeftIndex  = this.ifOverLeftSide(movement, C);
            if(stageMovedLeftIndex !== null) {
              this.currentMoveRight = null; // Resetting
              this.currentDrop = C.allStageViews[stageMovedLeftIndex - 1];
              this.manageVerticalLineLeft(C, stageMovedLeftIndex);
           }
          }
          
        };
       
        this.indicator.checkMovingOffScreen = function(C, movement, direction) {

          if(direction === "right") {

            if(movement.left - this.canvasContaining.scrollLeft() > 889) {
              this.canvasContaining.scrollLeft(movement.left - 889);
            }
          } else if (direction === "left") {

            var anchor = this.canvasContaining.scrollLeft();
            if(anchor > movement.left) {
              this.canvasContaining.scrollLeft((anchor - (anchor - movement.left)));
            }
          }
        };

        this.indicator.manageVerticalLineRight = function(C, index) {

          var place = (C.allStageViews[index].left + C.allStageViews[index].myWidth + 13);
          this.verticalLine.setLeft(place).setCoords();
        };

        this.indicator.manageVerticalLineLeft = function(C, index) {

          var place = (C.allStageViews[index].left - 25);
          this.verticalLine.setLeft(place).setCoords();
        };

        this.indicator.processMovement = function(stage, C, circleManager) {

          if(this.verticalLine.getVisible() === false) {
            this.backToOriginal(stage, C);
          } else {
            this.applyMovement(stage, C, circleManager, null);
          }

          console.log("Landed .... !: Dragged stage->", this.draggedStage.index);

          var pre_id = (this.currentDrop) ? this.currentDrop.model.id : null;
          ExperimentLoader.moveStage(stage.model.id, pre_id).then(function(dat) {
          }, function(err) {
            console.log(err);
          });

          this.setVisible(false);
          this.direction = null;
          this.verticalLine.setVisible(false);
      };

      this.indicator.backToOriginal = function(stageToBeReplaced, C) {
        
        var data;
        data = {
          stage: stageToBeReplaced.model
        };

        if(stageToBeReplaced.previousStage !== null) {
          C.addNewStage(data, stageToBeReplaced.previousStage, "move_stage_back_to_original"); // Remember we used this method to insert a new stage [It cant be used to insert at the very beginning]
        } else if(stageToBeReplaced.previousStage === null) {
          C.addNewStageAtBeginning(stageToBeReplaced, data);
        }
        C.canvas.renderAll();
      };

      this.indicator.applyMovement = function(stage_, C, circleManager, callBack) {

        var stage = this.draggedStage;

        var stageIndex = (this.currentDrop) ? this.currentDrop.index : 0;
        var model = this.draggedStage.model;
        var stageView = new stageDude(model, C.canvas, C.allStepViews, stageIndex, C, C.$scope, true);

        C.addNextandPrevious(this.currentDrop, stageView);

        if(stageIndex === 0 && !this.currentDrop) { //if we insert into the very first place.
          C.allStageViews.splice(stageIndex, 0, stageView);
        } else {
          C.allStageViews.splice(stageIndex + 1, 0, stageView);
        }

        this.moveStageGraphics(stageView, C, circleManager);
        C.canvas.remove(stage_.dots);
      };

      this.indicator.moveStageGraphics = function(stageView, C, circleManager) {

        stageView.updateStageData(1);
        stageView.render();
        C.configureStepsofNewStage(stageView, 0);
        C.correctNumbering();
        C.allStageViews[0].moveAllStepsAndStagesSpecial();
        circleManager.addRampLines();
        C.allStepViews[C.allStepViews.length - 1].circle.doThingsForLast(null, null);
        stageView.stageHeader();
        C.$scope.applyValues(stageView.childSteps[0].circle);
        stageView.childSteps[0].circle.manageClick(true);

      };

        this.indicator.clickManager = function(stage_, C, circleManager) {
          var stage = this.draggedStage, stageIndex = 0, model, stageView;
          this.backToOriginal(stage, C);
        };
        return this.indicator;
      },
    };
  }
]);
