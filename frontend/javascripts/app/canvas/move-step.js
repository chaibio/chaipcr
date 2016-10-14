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
  function(ExperimentLoader, previouslySelected, circleManager) {

    return {

      getMoveStepRect: function(me) {

        this.currentHit = 0;
        this.currentDrop = null;
        this.startPosition = 0;
        this.endPosition = 0;
        this.currentLeft = 0;
        this.direction = null;
        this.beaconMove = 0;

        var smallCircle = new fabric.Circle({
          radius: 6, fill: '#FFB300', stroke: "black", strokeWidth: 3, selectable: false,
          left: 48, top: 298, originX: 'center', originY: 'center', visible: false
        });

        var smallCircleTop = new fabric.Circle({
          radius: 5, fill: 'black', selectable: false, left: 48, top: 13, originX: 'center', originY: 'center', visible: false
        });

        var temperatureText = new fabric.Text(
          "20º", {
            fill: 'black',  fontSize: 20, selectable: false, originX: 'left', originY: 'top',
            top: 9, left: 1, fontFamily: "dinot-bold"
          }
        );

        var holdTimeText = new fabric.Text(
          "0:05", {
            fill: 'black',  fontSize: 20, selectable: false, originX: 'left', originY: 'top',
            top: 9, left: 59, fontFamily: "dinot"
          }
        );

        var indexText = new fabric.Text(
          "02", {
            fill: 'black',  fontSize: 16, selectable: false, originX: 'left', originY: 'top',
            top: 30, left: 17, fontFamily: "dinot-bold"
          }
        );

        var placeText= new fabric.Text(
          "01/01", {
            fill: 'black',  fontSize: 16, selectable: false, originX: 'left', originY: 'top',
            top: 30, left: 42, fontFamily: "dinot"
          }
        );

        var verticalLine = new fabric.Line([0, 0, 0, 276],{
          left: 47, top: 16, stroke: 'black', strokeWidth: 2, originX: 'left', originY: 'top', visible: false
        });

        var rect = new fabric.Rect({
          fill: 'white', width: 96, left: 0, height: 72, selectable: false, name: "step", me: this, rx: 1,
        });

        var coverRect = new fabric.Rect({
          fill: null, width: 96, left: 0, top: 0, height: 372, selectable: false, me: this, rx: 1,
        });

        me.imageobjects["drag-footer-image.png"].originX = "left";
        me.imageobjects["drag-footer-image.png"].originY = "top";
        me.imageobjects["drag-footer-image.png"].top = 52;
        me.imageobjects["drag-footer-image.png"].left = 9;

        indicatorRectangle = new fabric.Group([
          rect, temperatureText, holdTimeText, indexText, placeText,
          me.imageobjects["drag-footer-image.png"],
        ],
          {
            originX: "left", originY: "top", left: 0, top: 298, height: 72, selectable: true, lockMovementY: true, hasControls: false,
            visible: true, hasBorders: false, name: "dragStepGroup"
          }
        );

        this.indicator = new fabric.Group([coverRect, indicatorRectangle, verticalLine, smallCircle, smallCircleTop], {
          originX: "left", originY: "top", left: 38, top: 28, height: 372, width: 96, selectable: true,
          lockMovementY: true, hasControls: false, visible: false, hasBorders: false, name: "dragStepGroup"
        });

        this.indicator.beacon = new fabric.Rect({
          fill: '', width: 10, left: 0, top: 340, height: 10, selectable: false, me: this,
          lockMovementY: true, hasControls: false, visible: true, //fill: 'black',
        });

      this.indicator.verticalLine = verticalLine;
      this.indicator.smallCircleTop = smallCircleTop;
      this.indicator.smallCircle = smallCircle;

      this.indicator.init = function(step) {

        this.spaceArray = [step.parentStage.left - 20, step.parentStage.left + 30];
        console.log(step, "stepping");
        if(step.nextStep) {
          this.currentDrop = step.nextStep;
          this.currentHit = step.nextStep.index;
        } else if(step.parentStage.nextStage) {
          this.currentDrop = step.parentStage.nextStage.childSteps[0];
          this.currentHit = step.index;
        } else {
          console.log("I am last -- >");
          if(step.previousStep) {
            this.currentDrop = step.previousStep;
            this.currentHit = step.previousStep.index;
          } else if(step.parentStage.previousStage) {
            this.currentDrop = step.parentStage.previousStage.childSteps[step.parentStage.previousStage.childSteps.length - 1];
            this.currentHit = this.currentDrop.index;
          }
          }
      };

      this.indicator.changePlacing = function(footer) {

        this.setVisible(true);
        this.setLeft(footer.left);
        this.startPosition = footer.left;
      };

      this.indicator.changeText = function(step) {

        temperatureText.setText(step.model.temperature + "º");
        holdTimeText.setText(step.circle.holdTime.text);
        indexText.setText(step.numberingTextCurrent.text);
        placeText.setText(step.numberingTextCurrent.text + step.numberingTextTotal.text);
      };

      this.indicator.processMovement = function(step, C) {

        if(this.verticalLine.getVisible() === true) {
          this.verticalLine.setVisible(false);
          this.smallCircleTop.setVisible(false);
          this.smallCircle.setVisible(false);
        }
        // Make a clone of the step
        //if(Math.abs(this.startPosition - this.endPosition) > 65)
          var modelClone = $.extend({}, step.model);
          // We had shrinked the stage, Now we undo it.
          step.parentStage.expand();
          // Find the place where you left the moved step
          //var moveTarget = Math.floor((this.left + 60) / 120);
          var targetStep = this.currentDrop;

          var targetStage = targetStep.parentStage;

          // Delete the step, you moved
          step.parentStage.deleteStep({}, step);
          // add clone at the place
          var data = {
            step: modelClone
          };

          targetStage.addNewStep(data, targetStep);
          // console.log(modelClone.id, targetStep.model.id, targetStage.model.id);
          ExperimentLoader.moveStep(modelClone.id, targetStep.model.id, targetStage.model.id)
            .then(function(data) {
              console.log("Moved", data);
            });

      };

      this.indicator.onTheMove = function(C, movement) {
        console.log("Hola");
        this.setLeft(movement.left).setCoords();

        this.beacon.setLeft(movement.left + this.beaconMove).setCoords();

        if(this.verticalLine.getVisible() === false) {
          this.verticalLine.setVisible(true);
          this.smallCircleTop.setVisible(true);
          this.smallCircle.setVisible(true);
        }

        if(movement.left > this.currentLeft && this.direction !== "right") {
          this.direction = "right";
          this.beaconMove = 96;
        } else if(movement.left < this.currentLeft && this.direction !== "left") {
          this.direction = "left";
          this.beaconMove = -10;
        }

        this.currentLeft = movement.left;

        C.allStepViews.some(function(step, index) {

          if(this.intersectsWithObject(step.hitPoint) && this.currentHit !== index) {

              this.currentDrop = step;
              this.currentHit = index;
              return true;
          }
          return false;

        }, this);

        C.allStageViews.some(function(stage, index) {
          if(this.beacon.intersectsWithObject(stage.stageHitPointLowerLeft)) {
            console.log("hit left");
            if(this.direction === "left") {
              stage.moveToSide("right", this.verticalLine, this.spaceArray, "STEP");
            }
          } else if(this.beacon.intersectsWithObject(stage.stageHitPointLowerRight)) {
            console.log("hit right");
            if(this.direction === "right") {
              stage.moveToSide("left", this.verticalLine, this.spaceArray, "STEP");
            }
          }
        }, this);

        /*if(this.beacon.left > this.spaceArray[0] && this.beacon.left < this.spaceArray[1]) {
          if(this.verticalLine.getVisible() === false) {
            this.verticalLine.setVisible(true);
            this.smallCircleTop.setVisible(true);
            this.smallCircle.setVisible(true);
          }
        } else if(this.verticalLine.getVisible() === true) {
          this.verticalLine.setVisible(false);
          this.smallCircleTop.setVisible(false);
          this.smallCircle.setVisible(false);
        }*/

      };

      return this.indicator;

      },

    };
  }
]
);
