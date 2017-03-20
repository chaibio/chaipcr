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
  'Line',
  'Group',
  'Circle',
  'Text',
  'Rectangle',
  'stageRoof',
  'stageBorderLeft',
  'stageDotsBackground',
  'stageDots',
  'stageCaption',
  'stageName',
  'stageNameGroup',
  'stageRect',
  'stageGroup',
  function(dots, Line, Group, Circle, Text, Rectangle, stageRoof, stageBorderLeft, stageDotsBackground,
    stageDots, stageCaption, stageName, stageNameGroup,stageRect, stageGroup) {

    this.addRoof = function() {

      this.roof = new stageRoof(this.myWidth);
      return this;
    };

    this.borderLeft = function() {
      this.border =  new stageBorderLeft();
      return this;
    };

    this.dotsOnStage = function() {

      var editStageStatus = this.parent.editStageStatus;
      var dotsArray = dots.stageDots();

      this.dotsBackground = new stageDotsBackground(); // Background of move stage dots, for more accurate click.
      dotsArray.unshift(this.dotsBackground);

      this.dots = new stageDots(this, dotsArray, editStageStatus);
      return this;
    };

    this.writeMyName = function() {

      this.stageCaption = new stageCaption();


      this.stageName = new stageName();

      var editStageStatus = this.parent.editStageStatus;
      var addUp = (editStageStatus === true) ? 26 : 1;
      var moved = (editStageStatus === true) ? "right": false;

      this.stageNameGroup = new stageNameGroup([this.stageCaption, this.stageName], addUp, moved);
      return this;
    };

    this.createStageHitPoints = function() {

      var stageHitPointLeftProperties = {
        width: 10, height: 200, fill: '', left: this.left + 10, top: 10, selectable: false, name: "stageHitPointLeft",
        originX: 'left', originY: 'top', //fill: 'black'
      };

      var stageHitPointRightProperties = {
        width: 10, height: 200, fill: '', left: (this.left + this.width) - 20, top: 10, selectable: false, name: "stageHitPointRight",
        originX: 'left', originY: 'top', //fill: 'black'
      };

      var stageHitPointLowerLeftProperties = {
        width: 10, height: 10, fill: '', left: this.left + 10, top: 340, selectable: false, name: "stageHitPointLowerLeft",
        originX: 'left', originY: 'top', //fill: 'black'
      };

      var stageHitPointLowerRightProperties = {
        width: 10, height: 10, fill: '', left: (this.left + this.width) - 20, top: 340, selectable: false, name: "stageHitPointLowerRight",
        originX: 'left', originY: 'top', //fill: 'black'
      };

      var rightPointerDetectorProperties = {
        width: 30, height: 10, fill: '', left: (this.left + this.width) + 50, top: 10, selectable: false, name: "rightPointerDetector",
        originX: 'left', originY: 'top', //fill: 'black'
      };

      this.stageHitPointLeft = Rectangle.create(stageHitPointLeftProperties);
      this.stageHitPointRight = Rectangle.create(stageHitPointRightProperties);
      this.stageHitPointLowerLeft = Rectangle.create(stageHitPointLowerLeftProperties);
      this.stageHitPointLowerRight = Rectangle.create(stageHitPointLowerRightProperties);
      //this.moveStageRightPointerDetector = Rectangle.create(rightPointerDetectorProperties);

      return this;
    };

    this.recalculateStageHitPoint = function() {

      this.stageHitPointLeft.setLeft(this.left + 10).setCoords();
      this.stageHitPointRight.setLeft((this.left + this.myWidth) - 20).setCoords();

      this.stageHitPointLowerLeft.setLeft(this.left + 10).setCoords();
      this.stageHitPointLowerRight.setLeft((this.left + this.myWidth) - 20).setCoords();

      this.canvas.bringToFront(this.stageHitPointLowerLeft);
      this.canvas.bringToFront(this.stageHitPointLowerRight);
      //this.canvas.bringToFront(this.moveStageRightPointerDetector);
    };

    this.createStageRect = function() {

      this.stageRect = new stageRect();
      return this;
    };

    this.createStageGroup = function() {

      var stageContents = [this.stageRect, this.stageNameGroup, this.roof, this.border]; //this.dots
      this.stageGroup = new stageGroup(stageContents, this.left);
      return this;
    };

    return this;
  }
]);
