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
  'circleManager',
  function(circleManager) {

    var reference = this, parentEventReference = null, ParentKanvas = null, 
    originalScope;

    this.init = function(C, $scope, that) {

      parentEventReference = that;
      ParentKanvas = C;
      originalScope = $scope;

      this.canvas.on("mouse:up", reference.mouseUpHandler);
    };

    this.mouseUpHandler = function(evt) {

      if(parentEventReference.mouseDown) {
          parentEventReference.canvas.defaultCursor = "default";
          parentEventReference.startDrag = 0;
          parentEventReference.mouseDown = false;
          parentEventReference.canvas.renderAll();
        } else {
          parentEventReference.canvas.moveCursor = "move";
        }

        if(parentEventReference.moveStepActive) {
          var indicate = evt.target;
          step = indicate.parent;

          ParentKanvas.moveDots.setVisible(false);
          ParentKanvas.stepIndicator.setVisible(false);
          parentEventReference.moveStepActive = false;
          step.parentStage.updateWidth();
          ParentKanvas.stepIndicator.processMovement(step, ParentKanvas);
          ParentKanvas.canvas.renderAll();

        }

        if(parentEventReference.moveStageActive) {
          var stage = evt.target.parent;
          ParentKanvas.stageIndicator.processMovement(stage, circleManager);
          parentEventReference.moveStageActive = false;
          ParentKanvas.canvas.renderAll();
        }
    };
    return this;
  }
]);
