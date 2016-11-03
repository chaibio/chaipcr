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
  function(ExperimentLoader, previouslySelected, previouslyHoverd, scrollService, circleManager) {

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
          if(that.mouseDownPos === evt.e.clientX) {
            console.log("its just a click ", evt.target);
          }
          evt.target.parent.parentStage.shrinkedStage = false;
          C.moveDots.setVisible(false);
          C.moveDots.currentIndex = null;
          C.stepIndicator.setVisible(false);
          that.moveStepActive = false;
          C.canvas.renderAll();
        }

        if(that.moveStageActive) {
          if(that.mouseDownPos === evt.e.clientX) {
            // process movement here

            var stage = evt.target.parent;
            console.log(evt.target);
            //evt.target.setVisible(false);
            //C.canvas.remove(evt.target);
            //C.canvas.renderAll();
            //C.stageIndicator.processMovement(stage, C, circleManager);
            console.log("its just a click we conclude it as we want to switch places", stage);
            C.stageIndicator.clickManager(stage, C, circleManager);
          }
          //C.stageIndicator.setVisible(false);
          that.moveStageActive = false;
          C.canvas.renderAll();
        }
      });
    };
    return this;
  }
]);
