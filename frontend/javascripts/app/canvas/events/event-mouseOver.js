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

angular.module("canvasApp").factory('mouseOver', [
  'previouslyHoverd',
  function(previouslyHoverd) {

    var reference = this, parentEventReference = null, ParentKanvas = null, 
    originalScope;

    this.init = function(C, $scope, that) {

      parentEventReference = that;
      ParentKanvas = C;
      originalScope = $scope;

      var me;
      that = {
        canvas: {
          hoverCursor: "anything"
        }
      };

      this.canvas.on("mouse:over", reference.mouseOverHandler);
    };

    this.mouseOverHandler = function(evt) {

      if(! evt.target) return false;

        switch(evt.target.name) {

          case "stepGroup":
            reference.stepGroupHoverHandler(evt);
          break;

          case "controlCircleGroup":
            parentEventReference.canvas.hoverCursor = "pointer";
          break;

          case "moveStep":
            parentEventReference.canvas.hoverCursor = "pointer";
          break;

          case "moveStage":
            parentEventReference.canvas.hoverCursor = "pointer";
          break;

          case "deleteStepButton":
            parentEventReference.canvas.hoverCursor = "pointer";
          break;

        }
    };

    this.stepGroupHoverHandler = function(evt) {
       
        me = evt.target.me;

        if(ParentKanvas.editStageStatus === false) {
          if(originalScope.protocol.protocol.stages.length == 1 && originalScope.protocol.protocol.stages[0].stage.steps.length == 1){
            me.closeImage.animate('opacity', 0, {
              duration: 400,
              onChange: ParentKanvas.canvas.renderAll.bind(ParentKanvas.canvas),            
            });
          } else {
            me.closeImage.animate('opacity', 1, {
              duration: 400,
              onChange: ParentKanvas.canvas.renderAll.bind(ParentKanvas.canvas),            
            });
          }

          if(previouslyHoverd.step && (me.model.id !== previouslyHoverd.step.model.id)) {
            previouslyHoverd.step.closeImage.animate('opacity', 0, {
              duration: 400,
              onChange: ParentKanvas.canvas.renderAll.bind(ParentKanvas.canvas),
            });
          }
          previouslyHoverd.step = me;
          ParentKanvas.canvas.renderAll();
        }
    };
    return this;
  }
]);
