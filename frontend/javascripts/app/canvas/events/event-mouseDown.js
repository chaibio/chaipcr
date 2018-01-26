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
  'circleManager',
  'editMode',
  'movingStepGraphics',
  'correctNumberingService',
  function(ExperimentLoader, circleManager, editMode, movingStepGraphics, correctNumberingService) {

    /**************************************
        what happens when click is happening in canvas.
        what we do is check if the click is up on some particular canvas element.
        and we send the changes to angular directives.
    ***************************************/
    var reference = this, parentEventReference = null, ParentKanvas = null, originalScope;

    this.init = function(C, $scope, that) {
      // that originally points to event. Refer event.js
      var me;
      parentEventReference = that;
      ParentKanvas = C;
      originalScope = $scope;

      this.canvas.on("mouse:down", reference.mouseDownHandler);

    };

    this.unHookGroup = function(group, items, index_to_remove) {

        group._restoreObjectsState();
        ParentKanvas.canvas.remove(group);

        ParentKanvas.canvas.remove(items[index_to_remove]);

        items.splice(index_to_remove, 1);

        for(var i = 0; i < items.length; i++) {
          ParentKanvas.canvas.add(items[i]);
        }

        ParentKanvas.canvas.renderAll();
      };

      this.startEditing = function(textToBeEdited, evt) {

        ParentKanvas.canvas.setActiveObject(textToBeEdited);
        var clickedPlaceIndex = textToBeEdited.getSelectionStartFromPointer();

        textToBeEdited.enterEditing();
        for(var i = 0; i < clickedPlaceIndex; i++) {
          // Placing the cursor at the place where we clicked.
          textToBeEdited.moveCursorRightWithoutShift(evt);
        }
      };
    
    this.mouseDownHandler = function(evt) {

      var me;
      if(! evt.target) {
        parentEventReference.setSummaryMode();
        return false;
      }
      parentEventReference.mouseDown = true;
      switch(evt.target.name)  {      
        case "stepDataGroup":
          reference.stepDataGroupHandler(evt);
        break;

        case "stepGroup":
          me = evt.target.me;
          parentEventReference.selectStep(me.circle);
        break;

        case "controlCircleGroup":
          me = evt.target.me;
          parentEventReference.selectStep(me);
          parentEventReference.canvas.moveCursor = "ns-resize";
        break;

        case "moveStep":
            // Remember what we click and what we move is two different objects, once we click, rest of the graphics come by, So original reference point to ,
            // the very thing we click. Not to the one we move. This applies to moveStage too.          
          reference.moveStepHandler(evt);
        break;

        case "moveStage":
          reference.moveStageHandler(evt);
        break;

        case "deleteStepButton":
          reference.deleteStepHandler(evt);
        break;
  
      }
    };

    this.deleteStepHandler = function(evt) {

        me  = evt.target.me;
        parentEventReference.selectStep(me.circle);
        ExperimentLoader.deleteStep(originalScope)
        .then(function(data) {
          console.log("deleted", data);
          me.parentStage.deleteStep({}, me);
          ParentKanvas.canvas.renderAll();
        }); 
    };

    this.moveStageHandler = function(evt) {

        parentEventReference.mouseDownPos = evt.e.clientX;

        parentEventReference.moveStageActive = true;
        parentEventReference.canvas.moveCursor = "move";

        var stage = evt.target.parent;
        stage.collapseStage();
        parentEventReference.calculateMoveLimit("stage", stage);
        stage.wireStageNextAndPrevious();
        stage.removeFromStagesArray();
        correctNumberingService.correctNumbering();
        circleManager.togglePaths(false); //put it back later

        ParentKanvas.stageIndicator.init(evt.target.parent, ParentKanvas, evt.target);
        parentEventReference.stageIndicatorPosition = ParentKanvas.stageIndicator.left;
        ParentKanvas.stageIndicator.changeText(evt.target.parent);
        ParentKanvas.canvas.renderAll();

    };

    this.stepDataGroupHandler = function(evt) {

        var click = evt.e,
        target = evt.target,
        stepDataGroupLeft = target.left - 60,
        getP = parentEventReference.canvas.getPointer(evt.e);
        parentEventReference.selectStep(target.parentCircle);

        var group = target.parentCircle.stepDataGroup;
        var items = group._objects;
        var removeIndex = 0; // We have a rectangle mask in stepDataGroup, which we dont want to add when
        // editmode is active. so delete it before we add , so we send removeIndex. In this case rectangle mask is the
        // first element in the array.

        if(getP.x > stepDataGroupLeft && getP.x < (stepDataGroupLeft + 55)) {
          console.log("click on temp");
          this.unHookGroup(group, items, removeIndex);
          editMode.tempActive = true;
          editMode.currentActiveTemp = target.parentCircle.temperature;
          this.startEditing(target.parentCircle.temperature, evt);
        } else {
          console.log("click on time");
          if(! target.parentCircle.model.pause) {
            this.unHookGroup(group, items, removeIndex);
            editMode.holdActive = true;
            editMode.currentActiveHold = target.parentCircle.holdTime;
            this.startEditing(target.parentCircle.holdTime, evt);
          }
        }
    };

    this.moveStepHandler = function(evt) {

        var step = evt.target.parent;
        if(step.model.hold_time !== 0) {
        
          var backupStageModel = angular.copy(step.parentStage.model);
          movingStepGraphics.initiateMoveStepGraphics(step, ParentKanvas);
          // only if its not an infinite hold step we move the step
        
          parentEventReference.selectStep(step.circle);
          parentEventReference.calculateMoveLimit("step", evt.target);
          
          parentEventReference.moveStepActive = true;
          parentEventReference.canvas.moveCursor = "move";
          
          evt.target.setVisible(false);
          ParentKanvas.moveDots.baseStep = null;
          
          if(step.previousStep) {
            ParentKanvas.moveDots.baseStep = step.previousStep;
          }
          
          
          if(step.nextStep === null && step.previousStep === null) {
            
            step.parentStage.deleteStep({}, step);
            circleManager.togglePaths(false); //put it back later

            ParentKanvas.canvas.bringToFront(ParentKanvas.stepIndicator);
            // May be write a seperate init method for one step stage.
            ParentKanvas.stepIndicator.initForOneStepStage(step, evt.target, ParentKanvas, backupStageModel);
            ParentKanvas.canvas.renderAll();
            return null;
          }

          step.parentStage.squeezeStage(step);
          
          if(step.parentStage.nextStage) {
            
            step.parentStage.myWidth = step.parentStage.myWidth - 2;
            step.parentStage.nextStage.moveAllStepsAndStages(true); 
          }

          ParentKanvas.moveDots.setLeft(step.left + 6);
          ParentKanvas.moveDots.setCoords();
          ParentKanvas.moveDots.setVisible(true);
          ParentKanvas.canvas.bringToFront(ParentKanvas.moveDots);
          circleManager.togglePaths(false); //put it back later
          
          //ParentKanvas.canvas.bringToFront(ParentKanvas.stepIndicator);
          ParentKanvas.stepIndicator.init(step, evt.target, ParentKanvas, backupStageModel);
          ParentKanvas.canvas.renderAll();
        }
    };

    return this;
  }
]);
