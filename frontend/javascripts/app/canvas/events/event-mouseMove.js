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

angular.module("canvasApp").factory('mouseMove', [
  function() {

    var reference = this, parentEventReference = null, ParentKanvas = null, 
    originalScope, left, startPos;

    this.init = function(C, $scope, that) {
      
      parentEventReference = that;
      ParentKanvas = C;
      originalScope = $scope;

      this.canvasContaining = $('.canvas-containing');

      this.canvas.on("mouse:move", reference.handleMouseMove);
    };

    this.handleMouseMove = function(evt) {
      
      if(parentEventReference.mouseDown && evt.target) {

          if(parentEventReference.startDrag === 0) {
            parentEventReference.canvas.defaultCursor = "ew-resize";
            parentEventReference.startDrag = evt.e.clientX;
            startPos = this.canvasContaining.scrollLeft();
          }

          left = startPos - (evt.e.clientX - parentEventReference.startDrag); // Add startPos to reverse the moving direction.

          if((left >= 0) && (left <= originalScope.scrollWidth - 1024)) {

            originalScope.$apply(function() {
              originalScope.scrollLeft = left;
            });

            this.canvasContaining.scrollLeft(left);
          }
        }
    };

    return this;
  }
]);
