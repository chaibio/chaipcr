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

angular.module("canvasApp").factory('canvas', [
  'ExperimentLoader',
  '$rootScope',
  'stage',
  '$timeout',
  'events',
  'path',
  'stageEvents',
  'stepEvents',
  'moveStepRect',
  'moveStageRect',
  'previouslySelected',
  'constants',
  'circleManager',
  'dots',
  'interceptorFactory',
  'stageHitBlock',
  function(ExperimentLoader, $rootScope, stage, $timeout, events, path, stageEvents, stepEvents,
    moveStepRect, moveStageRect, previouslySelected, constants, circleManager, dots, interceptorFactory, stageHitBlock) {

    this.init = function(model) {

      this.model = model.protocol;
      this.$scope = model;
      this.allStepViews = [];
      this.allStageViews = [];
      this.canvas = null;
      this.allCircles = null;
      this.drawCirclesArray = [];
      this.findAllCirclesArray = [];
      this.moveLimit = 0; // We set the limit for the movement of the step image to move steps
      this.editStageStatus = false;
      this.dotCordiantes = {};

      this.images = [
        "gather-data.png",
        "gather-data-image.png",
        "pause.png",
        "pause-middle.png",
        "close.png",
        "drag-footer-image.png",
        "move-step-on.png",
        "drag-stage-image.png"
      ];

      this.imageLocation = "/images/";
      this.imageobjects = {};
      if(this.canvas) this.canvas.clear();
      this.canvas = new fabric.Canvas('canvas', {
        backgroundColor: '#FFB300', selection: false, stateful: true
      });
      circleManager.init(this);
      new events(this, this.$scope); // Fire the events;
      this.loadImages();
    };

    this.setDefaultWidthHeight = function() {

      this.canvas.setHeight(400);
      var stageCount = this.allStageViews.length;
      console.log("stageCount", stageCount);
      this.canvas.setWidth(
        (this.allStepViews.length * constants.stepWidth) +
        ((stageCount) * constants.newStageOffset) +
        ((stageCount) * constants.additionalWidth) +
        (constants.canvasSpacingFrontAndRear * 2)
      );
      var that = this, showScrollbar;
      // Show Hide scroll bar in the top
      this.$scope.scrollWidth = this.canvas.getWidth();
      this.$scope.showScrollbar = (this.canvas.getWidth() > 1024) ? true : false;
      //$timeout(function(context) {
        //context.canvas.renderAll();
        this.canvas.renderAll();
      //},0 , true, this);

      return this;
    };

    this.addStages = function() {

      var allStages = this.model.protocol.stages;
      var previousStage = null, noOfStages = allStages.length, stageView;

      this.allStageViews = allStages.map(function(stageData, index) {

        stageView = new stage(stageData.stage, this.canvas, this.allStepViews, index, this, this.$scope, false);
        // We connect the stages like a linked list so that we can go up and down.
        if(previousStage) {
          previousStage.nextStage = stageView;
          stageView.previousStage = previousStage;
        }

        previousStage = stageView;
        stageView.render();
        return stageView;
      }, this);

      console.log("Stages added ... !");
      return this;

    };

    /*******************************************************/
      /* This method does the default selection of the step when
         the graph is loaded. obviously allStepViews[0] is the very first step
         This could be changed later to reflext add/delete change*/
    /*******************************************************/
    this.selectStep = function() {

        this.allStepViews[0].circle.manageClick(true);
        this.$scope.fabricStep = this.allStepViews[0];
        // here we initiate stage/step events service.. So now we can listen for changes from the bottom.
        stageEvents.init(this.$scope, this.canvas, this);
        stepEvents.init(this.$scope, this.canvas, this);

        this.stepIndicator = moveStepRect.getMoveStepRect(this);
        this.stageIndicator = moveStageRect.getMoveStageRect(this);
        this.beacon = this.stageIndicator.beacon;
        this.emptySpace = this.stageIndicator.emptySpace;
        this.hitBlock = stageHitBlock.getStageHitBlock(this);

        this.canvas.add(this.stepIndicator);
        this.canvas.add(this.stageIndicator);
        this.canvas.add(this.beacon);
        this.canvas.add(this.emptySpace);
        this.canvas.add(this.hitBlock);
        this.addMoveDots();
    };

    this.addMoveDots = function() {

      var arr = dots.stepStageMoveDots();
      this.imageobjects["move-step-on.png"].setTop(328);
      this.imageobjects["move-step-on.png"].setLeft(-2);
      arr.push(this.imageobjects["move-step-on.png"]);
      this.moveDots = new fabric.Group(arr, {
        width: 13, left: 16, top: 35, backgroundColor: "white", visible: false
      });
      this.canvas.add(this.moveDots);
    };
    /*******************************************************/
      /* This method adds those footer images on the step. Its a tricky one beacuse images
         are taking longer time to load. So we load it once and clone it to all the steps.
         It uses recursive function to do the job. See the inner function mainWrapper()
      */
    /*******************************************************/

    this.loadImages = function() {

      var noOfImages = this.images.length - 1;
      var that = this;
      loadImageRecursion = function(index) {
        fabric.Image.fromURL(that.imageLocation + that.images[index], function(img) {
          that.imageobjects[that.images[index]] = img;
          if(index < noOfImages) {
            loadImageRecursion(++index);
          } else {
            that.canvas.fire("imagesLoaded");
          }
        });
      };

      loadImageRecursion(0);
    };

    this.editStageMode = function(status) {
      var add = (status) ? 25 : -25;

      if(status === true) {
        this.editStageStatus = status;
        previouslySelected.circle.parent.manageFooter("black");
        previouslySelected.circle.parent.parentStage.changeFillsAndStrokes("black", 4);
      } else {
        previouslySelected.circle.parent.manageFooter("white");
        previouslySelected.circle.parent.parentStage.changeFillsAndStrokes("white", 2);
        this.editStageStatus = status; // This order editStageStatus is changed is important, because changeFillsAndStrokes()
      }
      //console.log(this.allStageViews); // break the code later, into smaller functions, so that better integrate one stage one step scenario.
      // Rewrite part for one stage one step Scenario.
      var stageCount = this.allStageViews.length;
      var stepCount = this.allStepViews.length;

      this.allStageViews.forEach(function(stage, index) {
        //if(stageCount > 1) {
          stage.dots.setVisible(status);
          stage.stageNameGroup.left = stage.stageNameGroup.left + add;
        //}

        stage.childSteps.forEach(function(step, index) {
          //if(stepCount > 1) {
            step.closeImage.setVisible(status);
            step.dots.setVisible(status);
          //}

          if(step.parentStage.model.auto_delta) {
            if(step.index === 0) {
              step.deltaSymbol.setVisible(!status);
            }
            step.deltaGroup.setVisible(!status);
          }

        });
      }, this);
      this.canvas.renderAll();
    };

    this.makeSpaceForNewStage = function(data, currentStage, add) {

      data.stage.steps.forEach(function(step) {
        currentStage.myWidth = currentStage.myWidth + add;
        currentStage.moveAllStepsAndStages(false);
      });
      return currentStage;
    };

    this.addNextandPrevious = function(currentStage, stageView) {

      if(currentStage) {
        if(currentStage.nextStage) {
          stageView.nextStage = currentStage.nextStage;
          stageView.nextStage.previousStage = stageView;
        }
        currentStage.nextStage = stageView;
        stageView.previousStage = currentStage;
      } else if (! currentStage) { // if currentStage is null, It means we are inserting at very first
        stageView.nextStage = this.allStageViews[0];
        this.allStageViews[0].previousStage = stageView;
      }

    };

    this.configureStepsofNewStage = function(stageView, ordealStatus) {

      stageView.childSteps.forEach(function(step) {

        step.ordealStatus = ordealStatus + 1;
        step.render();
        this.allStepViews.splice(ordealStatus, 0, step);
        ordealStatus = ordealStatus + 1;
      }, this);
    };

    this.addNewStage = function(data, currentStage) {
      //move the stages, make space.
      var ordealStatus = currentStage.childSteps[currentStage.childSteps.length - 1].ordealStatus;
      var originalWidth = currentStage.myWidth;
      var add = (data.stage.steps.length > 0) ? 128 + Math.floor(constants.newStageOffset / data.stage.steps.length) : 128;

      currentStage = this.makeSpaceForNewStage(data, currentStage, add);
      // okay we puhed stages in front by inflating the current stage and put the old value back.
      currentStage.myWidth = originalWidth;

      // now create a stage;
      var stageIndex = currentStage.index + 1;
      var stageView = new stage(data.stage, this.canvas, this.allStepViews, stageIndex, this, this.$scope, true);

      this.addNextandPrevious(currentStage, stageView);
      stageView.updateStageData(1);
      this.allStageViews.splice(stageIndex, 0, stageView);
      stageView.render();
      // configure steps;
      this.configureStepsofNewStage(stageView, ordealStatus);
      circleManager.init(this);
      circleManager.addRampLinesAndCircles(circleManager.reDrawCircles());

      this.$scope.applyValues(stageView.childSteps[0].circle);
      stageView.childSteps[0].circle.manageClick(true);
      this.setDefaultWidthHeight();
    };

    this.resetStageMovedDirection = function() {

      this.allStageViews.forEach(function(stage, index) {
        console.log("nulling");
        stage.stageMovedDirection = null;
      });
    };

    this.correctNumbering = function() {
      var oStatus = 1;
      this.allStepViews = [];
      var that = this;
      this.allStageViews.forEach(function(stage, index) {
        stage.index = index;
        stage.stageCaption.setText("STAGE " + (index + 1) + ": " );
        stage.childSteps.forEach(function(step, index) {
          step.index = index;
          step.ordealStatus = oStatus;
          that.allStepViews.push(step);
          oStatus = oStatus + 1;
        });
      });
    };

    return this;
  }
]);
