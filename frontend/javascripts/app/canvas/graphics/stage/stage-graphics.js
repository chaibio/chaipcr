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
  'hitPoints',
  function(dots, Line, Group, Circle, Text, Rectangle, stageRoof, stageBorderLeft, stageDotsBackground,
    stageDots, stageCaption, stageName, stageNameGroup,stageRect, stageGroup, hitPoints) {

    this.addRoof = function() {

      this.roof = new stageRoof(this.myWidth);
      return this;
    };

    this.borderLeft = function() {
      this.border =  new stageBorderLeft();
      return this;
    };

    this.dotsOnStage = function() {
      
      this.dots = new stageDots(this);
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

      var allHitPoints = hitPoints.createAllHitPoints(this);

      this.stageHitPointLeft = allHitPoints.stageHitPointLeft;
      this.stageHitPointRight = allHitPoints.stageHitPointRight;
      this.stageHitPointLowerLeft = allHitPoints.stageHitPointLowerLeft;
      this.stageHitPointLowerRight = allHitPoints.stageHitPointLowerRight;
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
