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
  'stepHoldTimeService',
  function(editMode, stepHoldTimeService) {
    return function(model, parent, $scope) {

      this.model = model;
      var that = this;

      this.ifLastStep = function(step) {
          return step.parentStage.nextStage === null && step.nextStep === null;
      };

      this.isCyclingStage = function(step) {
          return step.parentStage.model.stage_type == 'cycling';
      };

      this.render = function() {

        this.holdTime = this.model.hold_time;
        var circleText = stepHoldTimeService.formatHoldTime(this.model.hold_time);
        if(this.ifLastStep(parent.parent) && !this.isCyclingStage(parent.parent) && !$scope.step.collect_data && this.holdTime == 0) {
          circleText = "∞";
        }
        this.text = new fabric.IText(circleText, {
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

      this.text.editingExited = function() {

        if(editMode.holdActive) {
          stepHoldTimeService.postEdit($scope, parent, that.text);
        }
      };

      // This block is executed when we hit enter.
      // This condition is a tricky one. When we hit enter text:editing:exited and editing:exited are called and
      // we dont need to execute twice. So in the first call, whichever it is editMode.tempActive is made false.
      this.text.on('text:editing:exited', this.text.editingExited);

      // This block works when we click somewhere else after enabling inline edit.
      this.text.on('editing:exited', this.text.editingExited);

      return this.text;
    };
  }
]);
