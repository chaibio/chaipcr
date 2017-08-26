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

angular.module("canvasApp").factory('mouseDown', [
  'ExperimentLoader',
  'previouslySelected',
  'previouslyHoverd',
  'scrollService',
  'circleManager',
  'editMode',
  '$timeout',
  'movingStepGraphics',
  'correctNumberingService',
  function(ExperimentLoader, previouslySelected, previouslyHoverd,
   scrollService, circleManager, editMode, $timeout, movingStepGraphics, correctNumberingService) {

    /**************************************
        what happens when click is happening in canvas.
        what we do is check if the click is up on some particular canvas element.
        and we send the changes to angular directives.
    ***************************************/

    this.init = function(C, $scope, that) {
      // that originally points to event. Refer event.js
      var me;
      this.canvas.on("mouse:down", function(evt) {
        
        if(! evt.target) {
          that.setSummaryMode();
          return false;
        }
        that.mouseDown = true;

        switch(evt.target.name)  {

          case "stepDataGroup":

            var click = evt.e,
            target = evt.target,
            stepDataGroupLeft = target.left - 60,
            getP = that.canvas.getPointer(evt.e);
            that.selectStep(target.parentCircle);

            var group = target.parentCircle.stepDataGroup;
            var items = group._objects;
            var removeIndex = 0; // We have a rectangle mask in stepDataGroup, which we dont want to add when
            // editmode is active. so delete it before we add , so we send removeIndex. In this case rectangle mask is the
            // first element in the array.

            if(getP.x > stepDataGroupLeft && getP.x < (stepDataGroupLeft + 55)) {
              console.log("click on temp");
              unHookGroup(group, items, removeIndex);
              editMode.tempActive = true;
              editMode.currentActiveTemp = target.parentCircle.temperature;
              startEditing(target.parentCircle.temperature, evt);
            } else {
              console.log("click on time");
              if(! target.parentCircle.model.pause) {
                unHookGroup(group, items, removeIndex);
                editMode.holdActive = true;
                editMode.currentActiveHold = target.parentCircle.holdTime;
                startEditing(target.parentCircle.holdTime, evt);
              }
            }

          break;

          case "stepGroup":

            me = evt.target.me;
            that.selectStep(me.circle);

          break;

          case "controlCircleGroup":

            me = evt.target.me;
            that.selectStep(me);
            that.canvas.moveCursor = "ns-resize";
          break;

          case "moveStep":
            // Remember what we click and what we move is two different objects, once we click, rest of the graphics come by, So original reference point to ,
            // the very thing we click. Not to the one we move. This applies to moveStage too.
            var step = evt.target.parent;
            if(step.model.hold_time !== 0) {
            
              var backupStageModel = angular.copy(step.parentStage.model);
              movingStepGraphics.initiateMoveStepGraphics(step, C);
              // only if its not an infinite hold step we move the step
            
              that.selectStep(step.circle);
              that.calculateMoveLimit("step", evt.target);
              
              that.moveStepActive = true;
              that.canvas.moveCursor = "move";
              
              evt.target.setVisible(false);
              C.moveDots.baseStep = null;
              
              if(step.previousStep) {
                C.moveDots.baseStep = step.previousStep;
              }
              
              
              if(step.nextStep === null && step.previousStep === null) {
                
                step.parentStage.deleteStep({}, step);
                circleManager.togglePaths(false); //put it back later

                C.canvas.bringToFront(C.stepIndicator);
                // May be write a seperate init method for one step stage.
                C.stepIndicator.initForOneStepStage(step, evt.target, C, backupStageModel);
                C.canvas.renderAll();
                return null;
              }

              step.parentStage.squeezeStage(step);
              
              if(step.parentStage.nextStage) {
                
                step.parentStage.myWidth = step.parentStage.myWidth - 2;
                step.parentStage.nextStage.moveAllStepsAndStages(true); 
              }

              C.moveDots.setLeft(step.left + 6).setCoords().setVisible(true);
              C.canvas.bringToFront(C.moveDots);
              circleManager.togglePaths(false); //put it back later
              
              C.canvas.bringToFront(C.stepIndicator);
              C.stepIndicator.init(step, evt.target, C, backupStageModel);
              C.canvas.renderAll();
            }

          break;

          case "moveStage":

            that.mouseDownPos = evt.e.clientX;

            that.moveStageActive = true;
            that.canvas.moveCursor = "move";

            var stage = evt.target.parent;
            stage.collapseStage();
            that.calculateMoveLimit("stage", stage);
            stage.wireStageNextAndPrevious();
            stage.removeFromStagesArray();
            correctNumberingService.correctNumbering();
            circleManager.togglePaths(false); //put it back later

            C.stageIndicator.init(evt.target.parent, C, evt.target);
            that.stageIndicatorPosition = C.stageIndicator.left;
            C.stageIndicator.changeText(evt.target.parent);
            C.canvas.renderAll();
          break;

          case "deleteStepButton":

            me  = evt.target.me;
            that.selectStep(me.circle);
            ExperimentLoader.deleteStep($scope)
            .then(function(data) {
              console.log("deleted", data);
              me.parentStage.deleteStep({}, me);
              C.canvas.renderAll();
            });
          break;
        }

      });

      unHookGroup = function(group, items, index_to_remove) {

        group._restoreObjectsState();
        C.canvas.remove(group);

        C.canvas.remove(items[index_to_remove]);

        items.splice(index_to_remove, 1);

        for(var i = 0; i < items.length; i++) {
          C.canvas.add(items[i]);
        }
        C.canvas.renderAll();
      };

      startEditing = function(textToBeEdited, evt) {

        C.canvas.setActiveObject(textToBeEdited);
        var clickedPlaceIndex = textToBeEdited.getSelectionStartFromPointer();

        textToBeEdited.enterEditing();
        for(var i = 0; i < clickedPlaceIndex; i++) {
          // Placing the cursor at the place where we clicked.
          textToBeEdited.moveCursorRightWithoutShift(evt);
        }
      };

    };

    return this;
  }
]);
