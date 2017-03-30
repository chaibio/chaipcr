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

angular.module("canvasApp").factory('mouseOut', [
  'ExperimentLoader',
  'previouslySelected',
  'previouslyHoverd',
  'scrollService',
  function(ExperimentLoader, previouslySelected, previouslyHoverd, scrollService) {

    this.init = function(C, $scope, that) {

      var me;
      this.canvas.on("mouse:out", function(evt) {
        if(! evt.target) return false;

        switch(evt.target.name) {

          case "stepGroup":
            // May be we need something in here
          break;
          case "controlCircleGroup":
            that.canvas.hoverCursor = "move";
          break;

          case "moveStep":
            that.canvas.hoverCursor = "move";
          break;

          case "moveStage":
            that.canvas.hoverCursor = "move";
          break;

          case "deleteStepButton":
            that.canvas.hoverCursor = "move";
          break;
          case "temperatureDisplayText":
            evt.target.trigger('editing:exited');
          break;
          case "holdTimeDisplayText":
            evt.target.trigger('editing:exited');
          break;

        }
      });
    };
    return this;
  }
]);
