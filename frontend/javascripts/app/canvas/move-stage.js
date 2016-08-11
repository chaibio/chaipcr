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
  function(ExperimentLoader, stageDude) {

    return {

      getMoveStageRect: function(me) {

        this.currentHit = 0;
        this.currentDrop = null;
        this.startPosition = 0;
        this.endPosition = 0;
        this.currentLeft = 0;
        this.direction = null;

        var smallCircle = new fabric.Circle({
          radius: 6, fill: 'white', stroke: "black", strokeWidth: 2, selectable: false,
          left: 69, top: 390, originX: 'center', originY: 'center',
        });

        var smallCircleTop = new fabric.Circle({
          fill: '#FFB300', radius: 6, strokeWidth: 3, selectable: false, stroke: "black",
          left: 69, top: 64, originX: 'center', originY: 'center'
        });

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

        var verticalLine = new fabric.Line([0, 0, 0, 336],{
          left: 68, top: 58, stroke: 'black', strokeWidth: 2, originX: 'left', originY: 'top'
        });

        var vertical = new fabric.Group([verticalLine, smallCircleTop, smallCircle], {
          originX: "left", originY: "top", left: 62, top: 56, selectable: true,
          lockMovementY: true, hasControls: false, hasBorders: false, name: "vertica"
        });

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

        this.indicator = new fabric.Group([coverRect, indicatorRectangle, vertical], {
          originX: "left", originY: "top", left: 38, top: 0, height: 372, width: 135, selectable: true,
          lockMovementY: true, hasControls: false, visible: false, hasBorders: false, name: "dragStageGroup"
        });

        // We may need two beacon, so that we have better control over where we move
        this.indicator.beacon = new fabric.Rect({
          fill: '', width: 10, left: 0, top: 10, height: 10, selectable: false, me: this,
          lockMovementY: true, hasControls: false, visible: true, fill: 'black',
        });

        this.indicator.emptySpace = new fabric.Rect({
          fill: '', width: 118, left: 0, top: 10, height: 10, selectable: false, me: this,
          lockMovementY: true, hasControls: false, visible: true, fill: 'black',
        });
        this.indicator.verticalLine = vertical;


        this.indicator.init = function(stage) {

          //this.emptySpace = [null, null];

          this.setLeft(stage.left - 1).setCoords();
          this.draggedStage = stage;
          this.stageBackUp = angular.extend({}, stage);

          if(stage.nextStage) {
            this.currentDrop = stage.nextStage;
            this.currentHit = stage.nextStage.index;
          } else if(stage.previousStage) {
            this.currentDrop = stage.previousStage;
            this.currentHit = stage.previousStage.index;
          }

          if(stage.nextStage) {
            //this.emptySpace[1] = stage.nextStage.index;
          }
          if(stage.previousStage) {
            //this.emptySpace[0] = stage.previousStage.index;
          }

          this.setVisible(true);
        };

        this.indicator.onTheMoveDragGroup = function(dragging) {

          this.setLeft(dragging.left - 1).setCoords();
          if(this.direction === "right") {
            this.beacon.setLeft(dragging.left + 135).setCoords();
          } else if(this.direction === "left") {
            this.beacon.setLeft(dragging.left - 10).setCoords();
          }
        };

        this.indicator.changePlacing = function(place) {

          //this.setCoords();

        };

        this.indicator.changeText = function(stage) {

          stageName.setText(stage.stageCaption.text);
          stageType.setText(stage.model.stage_type.toUpperCase());
        };

        this.indicator.onTheMove = function(C, movement) {
          // Here we hit test the movement of the MOVING STAGE

          if(movement.left > this.currentLeft && this.direction !== "right") {
            this.direction = "right";
          } else if(movement.left < this.currentLeft && this.direction !== "left") {
            this.direction = "left";
          }
          this.currentLeft = movement.left;

          C.allStageViews.some(function(stage, index) {

            if(this.beacon.intersectsWithObject(stage.stageHitPointLeft) && this.draggedStage.index !== index) {

              this.currentDrop = stage;
              this.currentHit = index;

              if(this.findInAndOut("left") === "OUT") {
                stage.moveToSide("right", this.verticalLine, this.emptySpace);
                //this.verticalLine.setVisible(true);

                if(stage.previousStage) {
                  this.currentDrop = stage.previousStage;
                } else {
                  this.currentDrop = null;
                }

              } else {
                this.verticalLine.setVisible(false);
              }
              return true;
            }

            if(this.beacon.intersectsWithObject(stage.stageHitPointRight) && this.draggedStage.index !== index) {

              this.currentDrop = stage;
              this.currentHit = index;

              if(this.findInAndOut("right") === "OUT") {
                stage.moveToSide("left", this.verticalLine, this.emptySpace);
                //this.verticalLine.setVisible(true);
              } else {
                this.verticalLine.setVisible(false);
              }
              return true;
            }

            return false;
          }, this);
        };

        this.indicator.findInAndOut = function(hitPointPosition) {

          if(hitPointPosition === "left") {
            if(this.direction === "right") {
              this.going = "IN";
            } else if(this.direction === "left" ) {
              this.going = "OUT";
              return this.going;
            }
          } else if(hitPointPosition === "right") {
            if(this.direction === "left") {
              this.going = "IN";
            }
            if(this.direction === "right") {
              this.going = "OUT";
              return this.going;
            }
          }

        };

        // Now improve the code to handle simple click on stage move, Now we dont handle this event.
        this.indicator.processMovement = function(stage, C, circleManager) {
          // Process movement here
          // objects are corrected now looking for visual part.
          console.log("Landed .... !: Dragged stage->", this.draggedStage.index, "current Hit ->", this.currentHit);
          var that = this;
          if(this.currentHit  > this.draggedStage.index) {
            // ready to move back
            this.applyMovement(stage, C, circleManager, function() {
              C.allStageViews.splice(that.draggedStage.index, 1);
            });
          } else if(this.currentHit < this.draggedStage.index) {
            // ready to move forward
            this.applyMovement(stage, C, circleManager, function() {
              C.allStageViews.splice(that.draggedStage.index + 1, 1);
            });
          } else {

            if(stage.previousStage) {
              this.currentDrop = stage.previousStage;
              this.currentHit = stage.previousStage.index;
              this.applyMovement(stage, C, circleManager, function() {
                C.allStageViews.splice(that.draggedStage.index + 1, 1);
              });
            } else if(stage.nextStage) {
              this.currentDrop = stage.nextStage;
              this.currentHit = stage.nextStage.index;
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
          C.resetStageMovedDirection();
      };
        // Need to correct movement, so that the moved stage fits in at right place ,
        // right now, it works for moving right.
        this.indicator.applyMovement = function(stage_, C, circleManager, callBack) {

          /*Sometimes user moves left first and then move right,
            leave the move stage over a stage and which has empty space in the left.
            We move to side and move if it is valid so that when we re render there is no spacing. */
          if(this.currentDrop) {
            this.currentDrop.moveToSide("left", null, null);
          }
          this.draggedStage.myWidth = 0;
          var stage = this.draggedStage;

          while(stage.index <= (this.currentHit - 1)) {
            stage.moveIndividualStageAndContents(stage, true);
            stage = stage.nextStage;
          }

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

          stageView.updateStageData(1);
          stageView.render();
          C.configureStepsofNewStage(stageView, 0);
          C.correctNumbering();
          stageView.moveAllStepsAndStages();
          circleManager.init(C);
          circleManager.addRampLinesAndCircles(circleManager.reDrawCircles());
          C.$scope.applyValues(stageView.childSteps[0].circle);
          stageView.childSteps[0].circle.manageClick(true);
        };

        return this.indicator;
      },
    };
  }
]);
