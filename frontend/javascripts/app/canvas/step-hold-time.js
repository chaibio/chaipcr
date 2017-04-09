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

angular.module("canvasApp").factory('stepHoldTime', [
  'editMode',
  'ExperimentLoader',
  'TimeService',
  'alerts',
  function(editMode, ExperimentLoader, TimeService, alerts) {
    return function(model, parent, $scope) {

      this.model = model;
      this.parent = parent;
      this.canvas = parent.canvas;
      var that = this;

      this.formatHoldTime = function() {

        /*var holdTimeHour = Math.floor(this.holdTime / 60);
        var holdTimeMinute = (this.holdTime % 60);

        holdTimeMinute = (holdTimeMinute < 10) ? "0" + holdTimeMinute : holdTimeMinute;*/

        return TimeService.newTimeFormatting(this.model.hold_time);
      };

      this.render = function() {

        this.holdTime = this.model.hold_time;

        this.text = new fabric.IText(this.formatHoldTime(), {
          fill: 'black',
          fontSize: 20,
          top : 0,
          left: 60,
          originX: "left",
          originY: "top",
          fontFamily: "dinot",
          selectable: false,
          hasBorder: false,
          editingBorderColor: '#FFB300',
          type: "holdTimeDisplay",
          name: "holdTimeDisplayText",
          visible: ! this.model.pause
        });
      };

      this.render();

      this.text.on('text:editing:exited', function() {

        // This block is executed when we hit enter.
        // This condition is a tricky one. When we hit enter text:editing:exited and editing:exited are called and
        // we dont need to execute twice. So in the first call, whichever it is editMode.tempActive is made false.
        if(editMode.holdActive) {
          that.postEdit();
        }

      });

      this.text.on('editing:exited', function() {
        // This block works when we click somewhere else after enabling inline edit.
        if(editMode.holdActive) {
          that.postEdit();
        }
      });

      this.ifLastStep = function(step) {
        return step.parentStage.nextStage === null && step.nextStep === null;
      };

      this.postEdit = function() {
        // There is some issues for, saving new hold_time for infinite hold, make sure uts corrected when new design comes.
        editMode.holdActive = false;
        editMode.currentActiveHold = null;
        var previousHoldTime = Number($scope.step.hold_time);
        var newHoldTime = Number(TimeService.convertToSeconds(this.text.text));


        if(! isNaN(newHoldTime) && (newHoldTime !== previousHoldTime)) { //Should unify this with step-hold-time-directives
          if(newHoldTime === 0) {
            if(this.ifLastStep(parent.parent) && ! $scope.step.collect_data) {
              $scope.step.hold_time = newHoldTime;
              ExperimentLoader.changeHoldDuration($scope).then(function(data) {
                console.log("saved", data);
              });
            } else {
              alerts.showMessage(alerts.holdDurationZeroWarning, $scope);
            }
          } else {
            $scope.step.hold_time = newHoldTime;
            ExperimentLoader.changeHoldDuration($scope).then(function(data) {
              console.log("saved", data);
            });
          }
        }

        /*if($scope.step.hold_time !== 0) { // If its zero server returns error , but make an exception for last step
          ExperimentLoader.changeHoldDuration($scope).then(function(data) {
            console.log("saved", data);
          });
        }*/

        parent.model.hold_time = $scope.step.hold_time;
        parent.createNewStepDataGroup();
        if(this.ifLastStep(parent.parent)) {
          parent.doThingsForLast(newHoldTime, previousHoldTime);
        }
        parent.canvas.renderAll();

      };

      return this.text;
    };
  }
]);
