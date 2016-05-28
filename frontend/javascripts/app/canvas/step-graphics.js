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

angular.module("canvasApp").factory('stepGraphics', [
  'dots',
  function(dots) {

    this.addName = function() {

      var stepName = "Step " +(this.index + 1);
      if(this.model.name) {
        stepName = (this.model.name).charAt(0).toUpperCase() + (this.model.name).slice(1).toLowerCase();
      }

      this.stepNameText = stepName;
      this.stepName = new fabric.Text(stepName, {
          fill: 'white',  fontSize: 12,  top : 20,  left: -1,  fontFamily: "dinot-regular",  selectable: false,
          originX: 'left', originY: 'top'
        }
      );

      return this;
    };

    this.stepFooter = function() {

      var editStageStatus = this.parentStage.parent.editStageStatus;

      this.dots = new fabric.Group(dots.stepDots(), {
        originX: "left", originY: "top", left: this.left + 16, top: 378, visible: editStageStatus, lockMovementY: true,
        hasBorders: false, hasControls: false, name: "moveStep", parent: this
      });
      return this;
    };

    this.deleteButton = function() {

      var editStageStatus = this.parentStage.parent.editStageStatus;

      this.closeImage = $.extend({}, this.parentStage.parent.imageobjects["close.png"]);
      this.closeImage.visible = editStageStatus;
      this.closeImage.originX = "left";
      this.closeImage.originY = "top";
      this.closeImage.left = this.left + 108;
      this.closeImage.top = 79;
      this.closeImage.name = "deleteStepButton";
      this.closeImage.me = this;
      this.closeImage.selectable = true;
      this.closeImage.hasBorders = false;
      this.closeImage.hasControls = false;

      return this;
    };

    this.autoDeltaDetails = function() {

      var model = this.parentStage.model;

      if(model.auto_delta && model.stage_type === "cycling") {
        var tempSymbol = (parseFloat(this.model.delta_temperature) < 0) ? "" : "+";
        var timeSymbol = (parseFloat(this.model.delta_duration_s) < 0) ? "" : "+";

        var deltaText = tempSymbol + this.model.delta_temperature + 'ºC,'+ timeSymbol + parseFloat(this.model.delta_duration_s) + 's';
        var startOnText = "Start Cycle: " + model.auto_delta_start_cycle;

        this.autoDeltaTempTime.setText(deltaText);
        this.autoDeltaStartCycle.setText(startOnText);

        if(! this.parentStage.parent.editStageStatus) { // If we are not in edit stage mode.
          this.deltaGroup.setVisible(true);

          if(this.index === 0) {
            this.deltaSymbol.setVisible(true);
          } else {
            this.deltaSymbol.setVisible(false);
          }
        }
      // ==============================//
      } else {
        this.deltaGroup.setVisible(false);
        this.deltaSymbol.setVisible(false);
      }

    };

    this.initAutoDelta = function() {

      this.deltaSymbol = this.autoDeltaStartCycle = new fabric.Text('Δ', {
          fill: 'white',  fontSize: 14,  top : 338,  left: 10,  fontFamily: "dinot",  selectable: false,
          originX: 'left', originY: 'top', fontWeight: 'bold', visible: false
        }
      );

      this.autoDeltaTempTime = new fabric.Text('-0.15ºC, +5.0s', {
          fill: 'white',  fontSize: 12,  top : 0, left: 0,  fontFamily: "dinot-regular",  selectable: false,
          originX: 'left', originY: 'top'
        }
      );
      this.autoDeltaStartCycle = new fabric.Text('Start Cycle: 5', {
          fill: 'white',  fontSize: 12,  top : 15,  left: 0,  fontFamily: "dinot-bold",  selectable: false,
          originX: 'left', originY: 'top',
        }
      );

      this.deltaGroup = new fabric.Group([this.autoDeltaTempTime, this.autoDeltaStartCycle], {
        originX: 'left', originY: 'top', top: 338, left: 24,  visible: false
      });
    };

    this.numberingValue = function() {

      var thisIndex = (this.index < 9) ? "0" + (this.index + 1) : (this.index + 1),
      noofSteps = this.parentStage.model.steps.length;
      thisLength = (noofSteps < 10) ? "0" + noofSteps : noofSteps;
      text = thisIndex + "/" + thisLength;

      this.numberingTextCurrent.setText(thisIndex);
      this.numberingTextTotal.setText("/" + thisLength);
      this.numberingTextTotal.setLeft(this.numberingTextCurrent.left + this.numberingTextCurrent.width);
      return this;
    };

    this.initNumberText = function() {

      this.numberingTextCurrent = new fabric.Text('wow', {
          fill: 'white',  fontSize: 12,  top : 7,  left: -1,  fontFamily: "dinot-bold",  selectable: false,
          originX: 'left', originY: 'top'
        }
      );

      this.numberingTextTotal = new fabric.Text('wow', {
          fill: 'white',  fontSize: 12,  top : 7,  fontFamily: "dinot",  selectable: false,
          originX: 'left', originY: 'top'
        }
      );

    };

    this.addBorderRight = function() {

      this.borderRight = new fabric.Line([-2, 42, -2, 362], {
          stroke: '#ff9f00',  left: (this.myWidth - 2), strokeWidth: 1, selectable: false,
          originX: 'left', originY: 'top'
        }
      );

      return this;
    };

    this.rampSpeed = function() {

      this.rampSpeedNumber = this.model.ramp.rate;

      this.rampSpeedText = new fabric.Text(String(this.rampSpeedNumber)+ "º C/s", {
          fill: 'black',  fontSize: 12, fontFamily: "dinot",  originX: 'left',  originY: 'top'
        }
      );

      this.underLine = new fabric.Line([0, 0, this.rampSpeedText.width, 0], {
          stroke: "#ffde00",  strokeWidth: 2, originX: 'left',  originY: 'top', top: 13,  left: 0
        }
      );

      this.rampSpeedGroup = new fabric.Group([
            this.rampSpeedText, this.underLine
          ], {
              selectable: true, hasControls: true,  originX: 'left',  originY: 'top', top : 0,  left: this.left + 5, evented: false
            }
      );

      if(this.rampSpeedNumber <= 0) {
        this.rampSpeedGroup.setVisible(false);
      }

      return this;
    };

    this.stepComponents = function() {

      this.hitPoint = new fabric.Rect({
        width: 10, height: 30, fill: '', left: this.left + 60, top: 335, selectable: false, name: "hitPoint",
        originX: 'left', originY: 'top',
      });

      this.stepRect = new fabric.Rect({
          fill: '#FFB300',  width: this.myWidth,  height: 363,  selectable: false,  name: "step", me: this
        }
      );

      this.stepGroup = new fabric.Group([this.stepRect, this.numberingTextCurrent, this.numberingTextTotal, this.stepName, this.deltaSymbol,
        this.deltaGroup, this.borderRight], {
        left: this.left || 33,  top: 28,  selectable: false,  hasControls: false,
        hasBoarders: false, name: "stepGroup",  me: this, originX: 'left', originY: 'top'
      });
    };

    return this;
  }
]);
