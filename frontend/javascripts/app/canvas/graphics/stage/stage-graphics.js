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
      this.border =  new stageBorderLeft(this);
      return this;
    };

    this.dotsOnStage = function() {

      this.dots = new stageDots(this);
      return this;
    };

    this.writeMyName = function() {
      
      this.stageNameGroup = new stageNameGroup(this);
      return this;
    };

    this.createStageRect = function() {

      this.stageRect = new stageRect();
      return this;
    };

    this.createStageGroup = function() {

      var stageContents = [this.stageRect, this.stageNameGroup, this.roof]; //this.dots
      this.stageGroup = new stageGroup(stageContents, this.left);
      return this;
    };

    return this;
  }
]);
