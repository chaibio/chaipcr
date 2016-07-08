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
  function(ExperimentLoader, previouslySelected, previouslyHoverd, scrollService, circleManager, editMode) {

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

            var click = evt.e, target = evt.target, stepDataGroupLeft = target.left - 46,
            getP = that.canvas.getPointer(evt.e);
            that.selectStep(target.parentCircle);

            var group = target.parentCircle.stepDataGroup;
            var items = group._objects;
            unHookGroup(group, items);

            if(getP.x > stepDataGroupLeft && getP.x < (stepDataGroupLeft + 45)) {
              editMode.tempActive = true;
              startEditing(target.parentCircle.temperature);
            } else {
              editMode.holdActive = true;
              startEditing(target.parentCircle.holdTime);
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
            that.mouseDownPos = evt.e.clientX;
            C.stepIndicator.init(evt.target.parent);
            evt.target.parent.toggleComponents(false);
            that.moveStepActive = true;
            that.canvas.moveCursor = "move";
            C.stepIndicator.changePlacing(evt.target);
            C.stepIndicator.changeText(evt.target.parent);
            that.calculateMoveLimit("step");
            circleManager.togglePaths(false); //put it back later
            C.moveDots.setLeft(evt.target.parent.left + 16);
            evt.target.parent.shrinkStep();
            C.moveDots.setVisible(true);
            C.canvas.bringToFront(C.moveDots);
            C.canvas.bringToFront(C.stepIndicator);
            C.canvas.renderAll();

          break;

          case "moveStage":

            that.mouseDownPos = evt.e.clientX;
            that.moveStageActive = true;
            that.canvas.moveCursor = "move";
            that.calculateMoveLimit("stage");
            circleManager.togglePaths(false); //put it back later

            C.stageIndicator.init(evt.target.parent);
            C.stageIndicator.changeText(evt.target.parent);
            C.canvas.bringToFront(C.stageIndicator);
            C.stageIndicator.changePlacing(evt.target);
            evt.target.parent.collapseStage();
            C.canvas.renderAll();
            // Move other stages
            // Shrink this stage


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

      unHookGroup = function(group, items) {

        group._restoreObjectsState();
        C.canvas.remove(group);
        for(var i = 0; i < items.length; i++) {
          C.canvas.add(items[i]);
        }
        C.canvas.renderAll();
      };

      startEditing = function(textToBeEdited) {
        C.canvas.setActiveObject(textToBeEdited);
        textToBeEdited.enterEditing();
        textToBeEdited.selectAll();
      };

    };

    return this;
  }
]);
