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
  'stageGraphics',
  'StagePositionService',
  function(ExperimentLoader, $rootScope, stage, $timeout, events, path, stageEvents, stepEvents,
    moveStepRect, moveStageRect, previouslySelected, constants, circleManager, dots, interceptorFactory, stageHitBlock, stageGraphics, 
    StagePositionService) {

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
        "drag-footer-image.png",
        "move-step-on.png",
        "drag-stage-image.png"
      ];

      this.imageLocation = "/images/";
      this.imageobjects = {};
      angular.element('.canvas-loading').hide();
      if(this.canvas) this.canvas.clear();
      this.canvas = new fabric.Canvas('canvas', {
        backgroundColor: '#FFB300', selection: false, stateful: true,
        perPixelTargetFind: true, renderOnAddRemove: false, skipTargetFind: false,
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

      var allStages;
      if(this.model.protocol) {
        allStages = this.model.protocol.stages;
      } else {
        // Tests take this data; need to plug data before this, [update when writing tests for canvas];
        allStages = [{"stage":{"id":405,"stage_type":"holding","name":"Holding Stage","num_cycles":1,"auto_delta":false,"auto_delta_start_cycle":1,"order_number":2,"steps":[{"step":{"id":699,"name":null,"temperature":"100.0","hold_time":4,"pause":false,"collect_data":false,"delta_temperature":"0.0","delta_duration_s":0,"order_number":0,"ramp":{"id":699,"rate":"0.0","collect_data":false}}},{"step":{"id":726,"name":null,"temperature":"76.7","hold_time":4,"pause":false,"collect_data":false,"delta_temperature":"0.0","delta_duration_s":0,"order_number":1,"ramp":{"id":726,"rate":"0.0","collect_data":false}}}]}},{"stage":{"id":411,"stage_type":"cycling","name":"Cycling Stage","num_cycles":40,"auto_delta":true,"auto_delta_start_cycle":1,"order_number":3,"steps":[{"step":{"id":700,"name":null,"temperature":"56.2","hold_time":5,"pause":false,"collect_data":false,"delta_temperature":"0.0","delta_duration_s":0,"order_number":0,"ramp":{"id":700,"rate":"5.0","collect_data":false}}},{"step":{"id":710,"name":null,"temperature":"0.0","hold_time":3,"pause":true,"collect_data":false,"delta_temperature":"0.0","delta_duration_s":0,"order_number":1,"ramp":{"id":710,"rate":"5.0","collect_data":false}}}]}},{"stage":{"id":413,"stage_type":"cycling","name":"Cycling Stage","num_cycles":40,"auto_delta":false,"auto_delta_start_cycle":1,"order_number":5,"steps":[{"step":{"id":714,"name":null,"temperature":"52.0","hold_time":1,"pause":false,"collect_data":false,"delta_temperature":"0.0","delta_duration_s":0,"order_number":0,"ramp":{"id":714,"rate":"0.0","collect_data":false}}},{"step":{"id":715,"name":null,"temperature":"70.9","hold_time":12,"pause":false,"collect_data":true,"delta_temperature":"0.0","delta_duration_s":0,"order_number":1,"ramp":{"id":715,"rate":"0.0","collect_data":true}}},{"step":{"id":702,"name":null,"temperature":"100.0","hold_time":180,"pause":true,"collect_data":false,"delta_temperature":"0.0","delta_duration_s":0,"order_number":2,"ramp":{"id":702,"rate":"0.0","collect_data":false}}}]}}];
      }
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
        this.stageVerticalLine = this.stageIndicator.verticalLine;
        this.stepBeacon = this.stepIndicator.beacon;
        this.stepBrick = this.stepIndicator.brick;
        this.hitBlock = stageHitBlock.getStageHitBlock(this);

        this.canvas.add(this.stepIndicator);
        this.canvas.add(this.stageIndicator);
        this.canvas.add(this.stageVerticalLine);

        this.canvas.add(this.stepBeacon);
        this.canvas.add(this.stepBrick);
        this.canvas.add(this.hitBlock);
        this.addMoveDots(); // This is for movestep
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
      //StagePositionService.getPositionObject(this.allStageViews);
      //console.log(StagePositionService.allPositions);
      var add = (status) ? 25 : -25;

      if(status === true) {
        this.editStageStatus = status;
        previouslySelected.circle.parent.manageFooter("black");
        previouslySelected.circle.parent.parentStage.changeFillsAndStrokes("black", 4);
      } else {
        previouslySelected.circle.parent.manageFooter("white");
        previouslySelected.circle.parent.parentStage.changeFillsAndStrokes("white", 2);
        this.editStageStatus = status; //This order editStageStatus is changed is important, because changeFillsAndStrokes()
      }

      // Rewrite part for one stage one step Scenario.
      var count = this.allStageViews.length - 1;
      this.allStageViews.forEach(function(stage, index) {
        this.editStageModeStage(stage, add, status, count, index);
      }, this);
      this.canvas.renderAll();
    };

    this.editStageModeStage = function(stage, add, status, count, stageIndex) {

      if(stageIndex === count) {

        var lastStep = stage.childSteps[stage.childSteps.length - 1];
        if(parseInt(lastStep.circle.model.hold_time) !== 0) {
          this.editModeStageChanges(stage, add, status);
        }
      } else {
        this.editModeStageChanges(stage, add, status);
      }

      stage.childSteps.forEach(function(step, index) {
        this.editStageModeStep(step, status);
      }, this);
    };

    this.editModeStageChanges = function(stage, add, status) {

      var leftVal = {};
      stage.dots.setVisible(status);
      stage.dots.setCoords();
      this.canvas.bringToFront(stage.dots);
      if(status === true) {

        if(stage.stageNameGroup.moved !== "right") {
          leftVal = {left: stage.stageNameGroup.left + 26};
          stage.stageNameGroup.set(leftVal).setCoords();
          stage.stageNameGroup.moved = "right";
        }
        if(stage.childSteps.length === 1) {
          stage.shortenStageName();
        }
      } else if(status === false) {
        if(stage.stageNameGroup.moved === "right") {
          leftVal = {left: stage.stageNameGroup.left - 26};
          stage.stageNameGroup.set(leftVal).setCoords();
          stage.stageNameGroup.moved = false;
        }
        stage.stageHeader();
      }
    };

    this.editStageModeStep = function(step, status) {

      step.closeImage.setOpacity(status);
      step.dots.setVisible(status).setCoords();


      if( step.parentStage.model.auto_delta ) {
        if( step.index === 0 ) {
          step.deltaSymbol.setVisible(!status);
        }
        step.deltaGroup.setVisible(!status);
      }
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
        //Important
        step.circle.moveCircle();
        step.circle.getCircle();
        //
        this.allStepViews.splice(ordealStatus, 0, step);
        ordealStatus = ordealStatus + 1;
      }, this);
    };

    this.addNewStage = function(data, currentStage, mode) {
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
      this.insertStageGraphics(stageView, ordealStatus, mode);
    };

    this.addNewStageAtBeginning = function(stageToBeReplaced, data) {

      var add = (data.stage.steps.length > 0) ? 128 + Math.floor(constants.newStageOffset / data.stage.steps.length) : 128;
      var stageIndex = 0;
      var stageView = new stage(data.stage, this.canvas, this.allStepViews, stageIndex, this, this.$scope, true);
      this.addNextandPrevious(null, stageView);
      this.allStageViews.splice(stageIndex, 0, stageView);

      stageView.updateStageData(1);
      stageView.render();
      this.insertStageGraphics(stageView, 0, "add_stage_at_beginning");
      /*this.configureStepsofNewStage(stageView, 0);
      this.correctNumbering();
      stageView.moveAllStepsAndStages();
      circleManager.addRampLines();
      this.allStepViews[this.allStepViews.length - 1].circle.doThingsForLast(null, null);
      stageGraphics.stageHeader.call(stageView);
      this.$scope.applyValues(stageView.childSteps[0].circle);
      stageView.childSteps[0].circle.manageClick(true);*/
    };

    this.insertStageGraphics = function(stageView, ordealStatus, mode) {

      this.configureStepsofNewStage(stageView, ordealStatus);
      this.correctNumbering();

      if(mode === "move_stage_back_to_original") {
        console.log("YES ", mode);
        this.allStageViews[0].getLeft();
        this.allStageViews[0].moveAllStepsAndStagesSpecial(false);
      } else {
        this.allStageViews[0].moveAllStepsAndStages(false);
        //stageView.moveAllStepsAndStages(false);
      }
      circleManager.addRampLines();
      stageView.stageHeader();
      this.$scope.applyValues(stageView.childSteps[0].circle);
      stageView.childSteps[0].circle.manageClick(true);
      this.setDefaultWidthHeight();
    };

    this.correctNumbering = function() {

      var oStatus = 1, that = this, tempCircle = null;
      this.allStepViews = [];
      this.allStageViews.forEach(function(stage, index) {
        stage.stageMovedDirection = null;
        stage.index = index;
        stage.stageCaption.setText("STAGE " + (index + 1) + ": " );

        stage.childSteps.forEach(function(step, index) {
          if(tempCircle) {
            tempCircle.next = step.circle;
            step.circle.previous = tempCircle;
          } else {
            step.circle.previous = null;
          }

          tempCircle = step.circle;
          step.index = index;
          step.ordealStatus = oStatus;
          that.allStepViews.push(step);
          oStatus = oStatus + 1;
        });
      });
      tempCircle.next = null;
    };

    return this;
  }
]);
