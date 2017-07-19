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

angular.module("canvasApp").service('stepGraphics', [
  'dots',
  'Line',
  'Group',
  'Circle',
  'Text',
  'Rectangle',
  'stepName',
  'stepFooter',
  'closeGroup',
  'deltaSymbol',
  'deltaGroup',
  'numberingText',
  'borderRight',
  'borderLeft',
  'rampSpeedGroup',
  'stepRect',
  'stepGroup',
  function(dots, Line, Group, Circle, Text, Rectangle, stepName, stepFooter, closeGroup, deltaSymbol,
    deltaGroup, numberingText, borderRight, borderLeft, rampSpeedGroup, stepRect, stepGroup) {

    this.addName = function() {

      this.stepName = new stepName(this.stepNameText);
      return this;
    };

    this.stepFooter = function() {

      this.dots = new stepFooter(this);
      return this;
    };

    this.deleteButton = function() {

      this.closeImage = new closeGroup(this);
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
      return this;
    };

    this.initAutoDelta = function() {

      this.deltaSymbol = new deltaSymbol();
      this.deltaGroup = new deltaGroup(this);
      return this;
    };

    this.initNumberText = function() {

      this.numberingTextCurrent = new numberingText('current');
      this.numberingTextTotal = new numberingText('Total'); // current/total
      return this;
    };

    this.addBorderRight = function() {

      this.borderRight = new borderRight(this);
      return this;
    };
    
    this.addBorderLeft = function() {

      this.borderLeft = new borderLeft();
      return this;
    };

    this.rampSpeed = function() {

      this.rampSpeedGroup = new rampSpeedGroup(this);
      return this;
    };

    this.stepComponents = function() {

      this.stepRect = new stepRect(this);
      this.stepGroup = new stepGroup(this);
      return this;
    };

    return this;
  }
]);
