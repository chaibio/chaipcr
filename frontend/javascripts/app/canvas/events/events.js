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

  /**************************************
    These are the main fabric events happening
    Remeber all the events are happening on the canvas, so we can't write
    handler for individual object. So the approch is different from DOM
    all the events are send from canvas and we check if the event has particular target.
  ***************************************/
angular.module("canvasApp").factory('events', [
  'ExperimentLoader',
  'previouslySelected',
  'popupStatus',
  'previouslyHoverd',
  'scrollService',
  'mouseOver',
  'mouseOut',
  'mouseDown',
  'objectMoving',
  'objectModified',
  'mouseMove',
  'mouseUp',
  'htmlEvents',
  'circleManager',
  'textChanged',
  function(ExperimentLoader, previouslySelected, popupStatus, previouslyHoverd, scrollService,
    mouseOver, mouseOut, mouseDown, objectMoving, objectModified, mouseMove, mouseUp, htmlEvents,
    circleManager, textChanged) {
    return function(C, $scope) {
      //console.log(window.canvasApp, 222);
      this.canvas = C.canvas;
      this.startDrag = 0; // beginning position of dragging
      this.mouseDown = false;
      this.mouseDownPos = 0;
      this.mouseUpPos = 0;
      this.moveStepActive = false;
      this.moveStageActive = false;
      var that = this;

      // Initiate all events // you may pass this instead of that.
      mouseOver.init.call(this, C, $scope, that);
      mouseOut.init.call(this, C, $scope, that);
      mouseDown.init.call(this, C, $scope, that);
      mouseMove.init.call(this, C, $scope, that);
      mouseUp.init.call(this, C, $scope, that);

      objectMoving.init.call(this, C, $scope, that);
      objectModified.init.call(this, C, $scope, that);

      textChanged.init.call(this, C, $scope, that);

      htmlEvents.init.call(this, C, that);

      // Methods
      this.setSummaryMode = function() {

        //if(C.editStageStatus === true) {
          //angular.element('#edit-stage').click();
        //}

        $scope.$apply(function() {
          $scope.summaryMode = true;
        });



        var circle = previouslySelected.circle;
        circle.parent.unSelectStep();
        circle.parent.parentStage.unSelectStage();
        circle.makeItSmall();
        C.canvas.renderAll();
      };

      this.selectStep = function(circle) {

        $scope.summaryMode = false;
        circle.manageClick();
        $scope.applyValuesFromOutSide(circle);
      };

      this.containInfiniteStep = function(step) {

        var stage = step.parentStage;
        if(stage.next) {
          return false;
        }

        var lastOne = stage.childSteps[stage.childSteps.length - 1];
        if(lastOne.circle.holdTime.text === "∞") {
          return true;
        }

        return false;
      };

      this.infiniteStep =  function(step) {

        if(step.circle.holdTime.text === "∞") {
          return true;
        }
        return false;

      };

      this.calculateMoveLimitforStage = function() {

        var lastStage = C.allStageViews[C.allStageViews.length - 1];
        var lastStep = C.allStepViews[C.allStepViews.length - 1];
        console.log("here");
      };

      this.calculateMoveLimit = function(moveElement, stage) {

        var lastStep = C.allStepViews[C.allStepViews.length - 1];
        var lastStage = C.allStageViews[C.allStageViews.length - 1];
        if(stage.index === lastStage.index) {
          C.moveLimit = stage.previousStage.left + stage.previousStage.myWidth;
          return;
        }

        if(lastStep.circle.holdTime.text === "∞") {
          if(moveElement === "step") {
            C.stepMoveLimit = ((lastStep.left + 3) - 120);
            return;
          } else if(moveElement === "stage") {
            C.moveLimit = ((lastStage.left) - 40);
            return;
          }
        }

         C.moveLimit = lastStep.left + 120;
         C.stepMoveLimit = lastStep.left;
      };

      this.footerMouseOver = function(indicate, me, moveElement) {

        indicate.changeText(me.parentStage.index, me.index);
        indicate.currentStep = me;
        C.moveLimit = that.calculateMoveLimit(moveElement);
        C.canvas.bringToFront(indicate);
        indicate.setLeft(me.left + 4);
        indicate.setCoords();
        indicate.setVisible(true);
        C.canvas.renderAll();

      };
      
      /**************************************
          A tricky one, fired from the DOM perspective. When we have long
          canvas and when we scroll canvas recalculate the offset.
      ***************************************/
      $(".canvas-containing").scroll(function(){
        C.canvas.calcOffset();
      });

      /**************************************
           When all the images are loaded up
           We fire this event
           Note that it takes some more time to load images, better avaoid images
           or wait for images to complete
      ***************************************/
      this.canvas.on("imagesLoaded", function() {

        C.addStages();
        C.setDefaultWidthHeight();

        circleManager.addRampLinesAndCircles();
        
        if(!C.$scope.protocol.id && !C.$scope.fabricStep) {
          // This is for test to work right, when working with fake data
          C.$scope.$watch = function() {
            return true;
          };
        }

        C.selectStep();
        C.initEvents();
        C.getComponents();
        C.addComponentsToStage();
        C.canvas.renderAll();
      });
    };
  }
]);
