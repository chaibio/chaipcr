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

angular.module("canvasApp").factory('stepTemperature', [
  'editMode',
  'ExperimentLoader',
  'moveRampLineService',
  function(editMode, ExperimentLoader, moveRampLineService) {
    return function(model, parent, $scope) {

      this.model = model;
      this.parent = parent;
      this.canvas = parent.canvas;
      this.stepData = this.model;
      var that = this;

      this.render = function() {
        var temp = parseFloat(this.stepData.temperature);
        temp = (temp < 100) ? temp.toFixed(1) : temp;

        this.text = new fabric.IText(temp +"º", {
          fill: 'black',
          fontSize: 20,
          originX: "left",
          originY: "top",
          top : 0,
          left: 0,
          fontFamily: "dinot-bold",
          selectable: false,
          hasBorder: false,
          editingBorderColor: '#FFB300',
          type: "temperatureDisplay",
          name: "temperatureDisplayText",
        });

      };

      this.render();

      this.text.on('text:editing:exited', function() {
        // This block is executed when we hit enter.
        // This condition is a tricky one. When we hit enter text:editing:exited and editing:exited are called and
        // we dont need to execute twice. So in the first call, whichever it is editMode.tempActive is made false.
        if(editMode.tempActive) {
          that.postEdit();
        }

      });

      this.text.on('editing:exited', function() {
        // This block works when we click somewhere else after enabling inline edit.
        if(editMode.tempActive) {
          that.postEdit();
        }
      });

      this.postEdit = function() {

        editMode.tempActive = false;
        editMode.currentActiveTemp = null;
        var tempFloat, tempNo = parseFloat(this.text.text.replace("º", ""));


        if(tempNo === 0) {
          tempFloat = 0;
        } else {
          tempFloat = Math.abs(parseFloat(this.text.text.replace("º", ""))) || $scope.step.temperature;
        }

        $scope.step.temperature = (tempFloat > 100) ? 100.0 :  tempFloat;

        ExperimentLoader.changeTemperature($scope).then(function(data) {
          console.log("saved", data);
        });
        parent.model.temperature = $scope.step.temperature;
        parent.circleGroup.top = parent.getTop().top;
        parent.createNewStepDataGroup();
        moveRampLineService.manageDrag(parent.circleGroup);
        parent.circleGroup.setCoords();
        parent.canvas.renderAll();
      };
      return this.text;
    };
  }
]);
