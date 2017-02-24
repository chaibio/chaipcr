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

angular.module("canvasApp").service('stageGraphics', [
  'dots',
  function(dots) {

    this.addRoof = function() {

      this.roof = new fabric.Line([0, 24, (this.myWidth), 24], {
          stroke: 'white', strokeWidth: 2, selectable: false, left: 0
        }
      );
      return this;
    };

    this.borderLeft = function() {

      this.border =  new fabric.Line([0, 70, 0, 390], {
          stroke: '#ff9f00',  left: 0, strokeWidth: 2, selectable: false
        }
      );
      return this;
    };

    this.dotsOnStage = function() {

      var editStageStatus = this.parent.editStageStatus;

      /*var supportRect = new fabric.Rect({
        left: -2,  top: -2, fill: '',  width: 20,  height: 20,
      });*/
      var dotsArray = dots.stageDots();
      //dotsArray.push(supportRect);

      this.dotsBackground = new fabric.Rect({
        width: 15, height: 14, fill: '#FFB300', left: 0, top: -2, selectable: false,
        originX: 'left', originY: 'top', //fill: 'black'
      });

      dotsArray.unshift(this.dotsBackground);

      this.dots = new fabric.Group(dotsArray, {
        originX: "left", originY: "top", left: this.left, top: 6, hasControls: false, width: 22, height: 22, visible: editStageStatus,
        parent: this, name: "moveStage", lockMovementY: true, hasBorders: false, selectable: true, backgroundColor: ''
      });
      return this;
    };

    this.stageHeader = function() {

      if(this.stageName) {
        var index = parseInt(this.index) + 1;
        var stageName = (this.model.name).toUpperCase().replace("STAGE", "");
        var text = (stageName).trim();
        this.stageCaption.setText("STAGE " + index + ": " );

        if(this.model.stage_type === "cycling") {
          var noOfCycles = this.model.num_cycles;
          noOfCycles = String(noOfCycles);
          text = text + ", " + noOfCycles + "x";
        }

        this.stageName.setText(text);
        this.stageName.setLeft(this.stageCaption.left + this.stageCaption.width);

        if(this.parent.editStageStatus && this.childSteps.length === 1) {
          this.shortenStageName();
        } else {
          this.shortStageName = false;
        }
      }
    };

    this.writeMyName = function() {

      this.stageCaption = new fabric.Text("", {
          fill: 'white', fontWeight: "400",  fontSize: 12,   fontFamily: "dinot-bold",
          originX: "left", originY: "top", selectable: true, left: 0
        }
      );

      this.stageName = new fabric.Text("", {
          fill: 'white', fontWeight: "400",  fontSize: 12,   fontFamily: "dinot",
          originX: "left", originY: "top", selectable: true
        }
      );

      var editStageStatus = this.parent.editStageStatus;
      var addUp = (editStageStatus === true) ? 26 : 1;
      var moved = (editStageStatus === true) ? "right": false;
      this.stageNameGroup = new fabric.Group([this.stageCaption, this.stageName], {
        originX: "left", originY: "top", selectable: true, top : 8, left: addUp, moved: moved
      });
      return this;
    };

    this.createStageHitPoint = function() {

      this.stageHitPointLeft = new fabric.Rect({
        width: 10, height: 200, fill: '', left: this.left + 10, top: 10, selectable: false, name: "stageHitPointLeft",
        originX: 'left', originY: 'top', //fill: 'black'
      });

      this.stageHitPointRight = new fabric.Rect({
        width: 10, height: 200, fill: '', left: (this.left + this.width) - 20, top: 10, selectable: false, name: "stageHitPointRight",
        originX: 'left', originY: 'top', //fill: 'black'
      });

      this.stageHitPointLowerLeft = new fabric.Rect({
        width: 10, height: 10, fill: '', left: this.left + 10, top: 340, selectable: false, name: "stageHitPointLowerLeft",
        originX: 'left', originY: 'top', //fill: 'black'
      });

      this.stageHitPointLowerRight = new fabric.Rect({
        width: 10, height: 10, fill: '', left: (this.left + this.width) - 20, top: 340, selectable: false, name: "stageHitPointLowerRight",
        originX: 'left', originY: 'top', //fill: 'black'
      });

      this.moveStageRightPointerDetector = new fabric.Rect({
        width: 30, height: 10, fill: '', left: (this.left + this.width) + 50, top: 10, selectable: false, name: "stageHitPointRight",
        originX: 'left', originY: 'top', //fill: 'black'
      });

      return this;
    };

    this.recalculateStageHitPoint = function() {

      this.stageHitPointLeft.setLeft(this.left + 10).setCoords();
      this.stageHitPointRight.setLeft((this.left + this.myWidth) - 20).setCoords();

      this.stageHitPointLowerLeft.setLeft(this.left + 10).setCoords();
      this.stageHitPointLowerRight.setLeft((this.left + this.myWidth) - 20).setCoords();

      //this.moveStageRightPointerDetector.setLeft(this.left + this.myWidth + 50).setCoords();

      this.canvas.bringToFront(this.stageHitPointLowerLeft);
      this.canvas.bringToFront(this.stageHitPointLowerRight);
      //this.canvas.bringToFront(this.moveStageRightPointerDetector);
    };

    this.createStageRect = function() {

      this.stageRect = new fabric.Rect({
          left: 0,  top: 0, fill: '#FFB300',  width: this.myWidth,  height: 400,  selectable: false
        });

      return this;
    };

    this.createStageGroup = function(stageContents) {

      this.stageGroup = new fabric.Group(stageContents, {
            originX: "left", originY: "top", left: this.left,top: 0, selectable: false, hasControls: false
          }
      );
      return this;
    };

    return this;
  }
]);
