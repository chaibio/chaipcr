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
  function() {
    var reference = this, parentEventReference = null, ParentKanvas = null, 
    originalScope, left, startPos;

    this.init = function(C, $scope, that) {

      parentEventReference = that;
      ParentKanvas = C;
      originalScope = $scope;

      this.canvas.on("mouse:out", reference.mouseOutHandler);
    };

    this.mouseOutHandler = function(evt) {

      if(! evt.target) return false;

        switch(evt.target.name) {

          case "controlCircleGroup":
            parentEventReference.canvas.hoverCursor = "move";
          break;

          case "moveStep":
            parentEventReference.canvas.hoverCursor = "move";
          break;

          case "moveStage":
            parentEventReference.canvas.hoverCursor = "move";
          break;

          case "deleteStepButton":
            parentEventReference.canvas.hoverCursor = "move";
          break;
        }
    };

    return this;
  }
]);
