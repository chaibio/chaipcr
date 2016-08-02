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
          left: 69, top: 64, originX: 'center', originY: 'center',
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
          left: 68, top: 58, stroke: 'black', strokeWidth: 2, originX: 'left', originY: 'top',
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

        indicatorRectangle = new fabric.Group([
          rect, stageName, stageType,
          me.imageobjects["drag-stage-image.png"],
        ],
          {
            originX: "left", originY: "top", left: 0, top: 0, height: 72, selectable: true, lockMovementY: true, hasControls: false,
            visible: true, hasBorders: false, name: "dragStageRect"
          }
        );

        this.indicator = new fabric.Group([coverRect, indicatorRectangle, verticalLine, smallCircle, smallCircleTop], {
          originX: "left", originY: "top", left: 38, top: 0, height: 372, width: 135, selectable: true,
          lockMovementY: true, hasControls: false, visible: false, hasBorders: false, name: "dragStageGroup"
        });

        this.indicator.beacon = new fabric.Rect({
          fill: 'black', width: 10, left: 0, top: 10, height: 10, selectable: false, me: this,
          lockMovementY: true, hasControls: false, visible: true,
        });

        this.indicator.init = function(stage) {

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
          //console.log("moving", this);

          if(movement.left > this.currentLeft && this.direction !== "right") {
            this.direction = "right";
          } else if(movement.left < this.currentLeft && this.direction !== "left") {
            this.direction = "left";
          }
          this.currentLeft = movement.left;
          C.allStageViews.some(function(stage, index) {

            if(this.beacon.intersectsWithObject(stage.stageHitPoint) && this.draggedStage.index !== index) {
              this.currentDrop = stage;
              this.currentHit = index;
            }
          }, this);
        };
        // Now improve the code to handle simple click on stage move, Now we dont handle this event.
        this.indicator.processMovement = function(stage, C, circleManager) {
          // Process movement here
          // objects are corrected now looking for visual part.
          console.log("Landed .... !: Dragged stage->", this.draggedStage.index, "current Hit ->", this.currentHit);
          var that = this;
          if(this.currentHit  > this.draggedStage.index) {
            console.log("ready to move back");
            this.applyMovement(stage, C, circleManager, function() {
              C.allStageViews.splice(that.draggedStage.index, 1);
            });
          } else if(this.currentHit < this.draggedStage.index) {
            console.log("ready to move forward", this.draggedStage.myWidth);
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
            } else {
              this.currentDrop = stage.nextStage;
              this.currentHit = stage.nextStage.index;
              this.applyMovement(stage, C, circleManager, function() {
                C.allStageViews.splice(that.draggedStage.index, 1);
              });
            }


          }

          var pre_id = (this.currentDrop) ? this.currentDrop.model.id : null;
          //console.log(stage.model.id, pre_id);
          ExperimentLoader.moveStage(stage.model.id, pre_id).then(function(dat) {
            //console.log("moved stage big time", dat);
          }, function(err) {
            console.log(err);
          });
      };

        this.indicator.applyMovement = function(stage_, C, circleManager, callBack) {

          this.draggedStage.wireStageNextAndPrevious();
          this.draggedStage.myWidth = 0;
          var stage = this.draggedStage;

          while(stage.index <= (this.currentHit - 1)) {
            stage.moveIndividualStageAndContents(stage, true);
            stage = stage.nextStage;
          }

          var stageIndex = this.currentDrop.index;
          var model = this.draggedStage.model;
          var stageView = new stageDude(model, C.canvas, C.allStepViews, stageIndex, C, C.$scope, true);

          C.addNextandPrevious(this.currentDrop, stageView);
          C.allStageViews.splice(stageIndex + 1, 0, stageView);
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
        this.indicator.applyMovement1 = function(stage_, C, circleManager, callBack) {

          //this.draggedStage.wireStageNextAndPrevious();
          this.draggedStage.myWidth = 0;
          var stage = this.draggedStage;
          console.log("->", stage.index, "->", this.currentHit);
          while(stage.index <= (this.currentHit - 1)) {
            stage.moveIndividualStageAndContents(stage, true);
            stage = stage.nextStage;
          }

          var stageIndex = this.currentDrop.index;
          var model = this.draggedStage.model;
          var stageView = new stageDude(model, C.canvas, C.allStepViews, stageIndex, C, C.$scope, true);

          C.addNextandPrevious(this.currentDrop, stageView);
          C.allStageViews.splice(stageIndex + 1, 0, stageView);
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
