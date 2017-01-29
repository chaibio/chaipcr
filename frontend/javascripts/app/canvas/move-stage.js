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

  function(ExperimentLoader, stageDude, stageGraphics) {

    return {

      getMoveStageRect: function(me) {

        this.currentHit = 0;
        this.currentDrop = null;
        this.startPosition = 0;
        this.endPosition = 0;
        this.currentLeft = 0;
        this.direction = null;
        this.beaconMove = 0;

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
        /*******************Vertical line*************************/
        var smallCircle = new fabric.Circle({
          radius: 6, fill: 'white', stroke: "black", strokeWidth: 2, selectable: false,
          left: 69, top: 390, originX: 'center', originY: 'center',
        });

        var smallCircleTop = new fabric.Circle({
          fill: '#FFB300', radius: 6, strokeWidth: 3, selectable: false, stroke: "black",
          left: 69, top: 64, originX: 'center', originY: 'center'
        });

        var verticalLine = new fabric.Line([0, 0, 0, 336],{
          left: 68, top: 58, stroke: 'black', strokeWidth: 2, originX: 'left', originY: 'top'
        });

        var vertical = new fabric.Group([verticalLine, smallCircleTop, smallCircle], {
          originX: "left", originY: "top", left: 62, top: 56, selectable: true,
          lockMovementY: true, hasControls: false, hasBorders: false, name: "vertica", visible: false
        });
        /********************************************/
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

        // We may need two beacon, so that we have better control over where we move

        this.indicator.beacon = new fabric.Rect({
          fill: '', width: 10, left: 0, top: 10, height: 200, selectable: false, me: this,
          lockMovementY: true, hasControls: false, visible: true, //fill: 'black',
        });

        this.indicator.verticalLine = vertical;

        this.indicator.init = function(stage) {
          // rework on this part for smaller space...
          this.setLeft(stage.left - 50).setCoords();
          this.setVisible(true);
          this.lastHitLeft = null;
          this.canvasContaining = $('.canvas-containing');
          this.currentDragPos = 0;
          this.spaceArrayRight = [stage.left + stage.myWidth + 40, stage.left + stage.myWidth + 78];
          this.spaceArrayLeft = [stage.left - 80, stage.left + 42];
          this.draggedStage = stage;

          if(stage.nextStage) {
            this.currentDrop = stage.nextStage;
            this.currentHit = stage.nextStage.index;
          } else if(stage.previousStage) {
            this.currentDrop = stage.previousStage;
            this.currentHit = stage.previousStage.index;
          }
        };

        this.indicator.changeText = function(stage) {

          stageName.setText(stage.stageCaption.text);
          stageType.setText(stage.model.stage_type.toUpperCase());
        };

        this.indicator.onTheMove = function(C, movement) {
          // Here we hit test the movement of the MOVING STAGE
          this.setLeft(movement.left - 50).setCoords();
          this.beacon.setLeft(movement.left + this.beaconMove).setCoords();

          if(movement.left > this.currentLeft && this.direction !== "right") {
            this.direction = "right";
            this.beaconMove = 85;
          } else if(movement.left < this.currentLeft && this.direction !== "left") {
            this.direction = "left";
            this.beaconMove = -60;
          }

          this.currentLeft = movement.left;
          this.checkMovingOffScreen(C, movement, this.direction);

          C.allStageViews.some(function(stage, index) {

            if(this.beacon.intersectsWithObject(stage.stageHitPointLeft) && this.draggedStage.index !== index) {

              this.currentDrop = stage;
              this.currentHit = index;

              if(this.direction === "left") {
                stage.moveToSide("right", this.verticalLine, this.spaceArrayRight, this.spaceArrayLeft);
                this.lastHitLeft = stage;

                if(stage.previousStage) {
                  this.currentDrop = stage.previousStage;
                  this.currentHit = this.draggedStage.index - 1;
                } else {
                  this.currentDrop = null;
                  this.currentHit = 0;
                }
              }
              if(this.direction === "right") {
                this.currentDrop = stage.previousStage;
                this.currentHit = index - 1;
              }
              return true;
            } else if(this.beacon.intersectsWithObject(stage.stageHitPointRight) && this.draggedStage.index !== index) {
              this.currentDrop = stage;
              this.currentHit = index;

              if(this.direction === "right") {
                stage.moveToSide("left", this.verticalLine, this.spaceArrayRight, this.spaceArrayLeft);
              }
              return true;
            }

            return false;
            // END OF SOME METHOD.
          }, this);
          this.manageVerticalLine(C);


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

        this.indicator.manageVerticalLine = function(C, lastHitLeft) {
          //console.log(lastHitLeft.index);
          if(this.direction === 'right') {
            if(this.beacon.left > this.spaceArrayRight[0] && this.beacon.left < this.spaceArrayRight[1]) {
              if(this.verticalLine.getVisible() === false) {

                if(this.currentDrop) {
                  var verticalDropPositionRight = 0;
                  if(this.currentDrop.nextStage) {
                    verticalDropPositionRight = (this.currentDrop.left + this.currentDrop.myWidth + this.currentDrop.nextStage.left) / 2;
                  } else {
                    console.log("I am in this place");
                    verticalDropPositionRight = this.currentDrop.left + this.currentDrop.myWidth + 20;
                  }
                  this.verticalLine.setLeft(verticalDropPositionRight - 5).setCoords();
                }
                C.canvas.bringToFront(this.verticalLine);
                this.verticalLine.setVisible(true);
              }
            } else if(this.verticalLine.getVisible() === true) {
              this.verticalLine.setVisible(false);
            }
          } else if(this.direction === 'left') {
            if(this.beacon.left > this.spaceArrayLeft[0] && this.beacon.left < this.spaceArrayLeft[1]) {
              if(this.verticalLine.getVisible() === false) {
                if(this.lastHitLeft) {
                  console.log("bingo", this.lastHitLeft.left);
                  var verticalDropPositionLeft = this.lastHitLeft.left - 20;
                  if(this.lastHitLeft.previousStage) {
                    verticalDropPositionLeft = ((this.lastHitLeft.previousStage.left + this.lastHitLeft.previousStage.myWidth + this.lastHitLeft.left) / 2) - 5;
                  }
                  this.verticalLine.setLeft(verticalDropPositionLeft).setCoords();
                  C.canvas.bringToFront(this.verticalLine);
                  this.verticalLine.setVisible(true);
                  this.lastHitLeft = null;
                }

              }
            } else if(this.verticalLine.getVisible() === true) {
              this.verticalLine.setVisible(false);
            }
          }

        };

        this.indicator.processMovement = function(stage, C, circleManager) {
          // Process movement here
          // objects are corrected now looking for visual part.

          // 1) infinite hold has to be corrected while moving stage.
          // 2) processMovement has to be defrgged and simplified, Its complex.
          // May be we should splice the stage off from allStageViews right after we click on dots.
          if(this.verticalLine.getVisible() === false) {
            console.log("This is invalid");
            var stageToBeReplaced = this.draggedStage;
            this.backToOriginal(stageToBeReplaced, C, stage);
            this.setVisible(false);
            return true;
          }

          this.setVisible(false);
          console.log("Landed .... !: Dragged stage->", this.draggedStage.index, "current Hit ->", this.currentHit);

          var that = this;

          if(this.currentHit  > this.draggedStage.index) {
            console.log("Greater", this.currentDrop);
            // Patch
            var checkStage = this.draggedStage.nextStage;
            if(checkStage.nextStage === null) {
              var lastStep = checkStage.childSteps[checkStage.childSteps.length - 1];
              if(lastStep.model.hold_time === 0) {
                this.backToOriginal(this.draggedStage, C, stage);
                return true;
              }
            }
              this.applyMovement(stage, C, circleManager, function() {
                C.allStageViews.splice(that.draggedStage.index, 1);
              });
          } else if(this.currentHit < this.draggedStage.index) {
            // ready to move forward
            console.log("Lesser");
            this.applyMovement(stage, C, circleManager, function() {
              C.allStageViews.splice(that.draggedStage.index + 1, 1);
            });
          } else {
            console.log("Equal");
            if(stage.previousStage) {
              this.currentDrop = stage.previousStage;
              this.currentHit = stage.previousStage.index;
              this.applyMovement(stage, C, circleManager, function() {
                C.allStageViews.splice(that.draggedStage.index + 1, 1);
              });
            } else if(stage.nextStage) {
              console.log("I have next");
              //this.currentDrop = stage.nextStage;
              //this.currentHit = stage.nextStage.index;
              this.applyMovement(stage, C, circleManager, function() {
                C.allStageViews.splice(that.draggedStage.index, 1);
              });
            }
          }

          var pre_id = (this.currentDrop) ? this.currentDrop.model.id : null;
          ExperimentLoader.moveStage(stage.model.id, pre_id).then(function(dat) {
          }, function(err) {
            console.log(err);
          });

          this.direction = null;
      };

      this.indicator.backToOriginal = function(stageToBeReplaced, C, stage_) {

        var data;
        data = {
          stage: stageToBeReplaced.model
        };

        C.allStageViews.splice(stageToBeReplaced.index, 1);
        if(stageToBeReplaced.previousStage !== null) {
          C.addNewStage(data, stageToBeReplaced.previousStage, "move_stage_back_to_original"); // Remember we used this method to insert a new stage [It cant be used to insert at the very beginning]
        } else if(stageToBeReplaced.previousStage === null) {
          C.addNewStageAtBeginning(stageToBeReplaced, data);
        }
        C.canvas.renderAll();
      };

        this.indicator.applyMovement = function(stage_, C, circleManager, callBack) {
          console.log("Entering apply movement");
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

          callBack();

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
          stageGraphics.stageHeader.call(stageView);
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
