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

angular.module("canvasApp").factory('mouseUp', [
  'ExperimentLoader',
  'previouslySelected',
  'previouslyHoverd',
  'scrollService',
  'circleManager',
  'movingStepGraphics',
  function(ExperimentLoader, previouslySelected, previouslyHoverd, scrollService, circleManager, movingStepGraphics) {

    this.init = function(C, $scope, that) {

      this.canvas.on("mouse:up", function(evt) {

        if(that.mouseDown) {
          that.canvas.defaultCursor = "default";
          that.startDrag = 0;
          that.mouseDown = false;
          that.canvas.renderAll();
        } else {
          that.canvas.moveCursor = "move";
        }

        if(that.moveStepActive) {
          console.log("Loxxxxxxx");
          var indicate = evt.target;
          step = indicate.parent;

          C.moveDots.setVisible(false);
          C.stepIndicator.setVisible(false);
          that.moveStepActive = false;
          step.parentStage.updateWidth();
          C.stepIndicator.processMovement(step, C);
          C.canvas.renderAll();

        }

        if(that.moveStageActive) {
          var stage = evt.target.parent;
          C.stageIndicator.processMovement(stage, circleManager);
          that.moveStageActive = false;
          C.canvas.renderAll();
        }
      });
    };
    return this;
  }
]);
