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
  'events',
  'stage',
  'stageEvents',
  'stepEvents',
  'moveStepRect',
  'moveStageRect',
  'constants',
  'circleManager',
  'dots',
  'StagePositionService',
  'StepPositionService',
  'Line',
  'Group',
  'correctNumberingService',
  'editModeService',
  'addStageService',
  'loadImageService',
  function(events, stage, stageEvents, stepEvents, moveStepRect, moveStageRect, constants, circleManager, dots, StagePositionService, 
  StepPositionService, Line, Group, correctNumberingService, editModeService, addStageService, loadImageService) {

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
      this.stepMoveLimit = 0; // Limit when we move a step
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

      this.canvas = new fabric.Canvas('canvas', {
        backgroundColor: '#FFB300', selection: false, stateful: true,
        perPixelTargetFind: true, renderOnAddRemove: false, skipTargetFind: false,
      });

      circleManager.init(this);
      correctNumberingService.init(this);
      editModeService.init(this);
      addStageService.init(this);
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
      //if(this.model.protocol) {
        allStages = this.model.protocol.stages;
      //} //else {
        // Tests take this data; need to plug data before this, [update when writing tests for canvas];
        //allStages = [{"stage":{"id":405,"stage_type":"holding","name":"Holding Stage","num_cycles":1,"auto_delta":false,"auto_delta_start_cycle":1,"order_number":2,"steps":[{"step":{"id":699,"name":null,"temperature":"100.0","hold_time":4,"pause":false,"collect_data":false,"delta_temperature":"0.0","delta_duration_s":0,"order_number":0,"ramp":{"id":699,"rate":"0.0","collect_data":false}}},{"step":{"id":726,"name":null,"temperature":"76.7","hold_time":4,"pause":false,"collect_data":false,"delta_temperature":"0.0","delta_duration_s":0,"order_number":1,"ramp":{"id":726,"rate":"0.0","collect_data":false}}}]}},{"stage":{"id":411,"stage_type":"cycling","name":"Cycling Stage","num_cycles":40,"auto_delta":true,"auto_delta_start_cycle":1,"order_number":3,"steps":[{"step":{"id":700,"name":null,"temperature":"56.2","hold_time":5,"pause":false,"collect_data":false,"delta_temperature":"0.0","delta_duration_s":0,"order_number":0,"ramp":{"id":700,"rate":"5.0","collect_data":false}}},{"step":{"id":710,"name":null,"temperature":"0.0","hold_time":3,"pause":true,"collect_data":false,"delta_temperature":"0.0","delta_duration_s":0,"order_number":1,"ramp":{"id":710,"rate":"5.0","collect_data":false}}}]}},{"stage":{"id":413,"stage_type":"cycling","name":"Cycling Stage","num_cycles":40,"auto_delta":false,"auto_delta_start_cycle":1,"order_number":5,"steps":[{"step":{"id":714,"name":null,"temperature":"52.0","hold_time":1,"pause":false,"collect_data":false,"delta_temperature":"0.0","delta_duration_s":0,"order_number":0,"ramp":{"id":714,"rate":"0.0","collect_data":false}}},{"step":{"id":715,"name":null,"temperature":"70.9","hold_time":12,"pause":false,"collect_data":true,"delta_temperature":"0.0","delta_duration_s":0,"order_number":1,"ramp":{"id":715,"rate":"0.0","collect_data":true}}},{"step":{"id":702,"name":null,"temperature":"100.0","hold_time":180,"pause":true,"collect_data":false,"delta_temperature":"0.0","delta_duration_s":0,"order_number":2,"ramp":{"id":702,"rate":"0.0","collect_data":false}}}]}}];
      //}

      this.tempPreviousStage = null;

      this.allStageViews = allStages.map(this.addStagesMapCallback, this);

      StagePositionService.init(this.allStageViews);
      StepPositionService.init(this.allStepViews);

      console.log("Stages added ... !");
      return this;
    };

    this.addStagesMapCallback = function(stageData, index) {
      
      stageView = new stage(stageData.stage, this, index, false, this.$scope);
      // We connect the stages like a linked list so that we can go up and down.
      if(this.tempPreviousStage) {
        this.tempPreviousStage.nextStage = stageView;
        stageView.previousStage = this.tempPreviousStage;
      }

      this.tempPreviousStage = stageView;
      stageView.render();
      return stageView;
    };

    /*******************************************************/
      /* This method does the default selection of the step when
         the graph is loaded. obviously allStepViews[0] is the very first step
         This could be changed later to reflext add/delete change*/
    /*******************************************************/
    this.selectStep = function() {

        this.allStepViews[0].circle.manageClick(true);
        this.$scope.fabricStep = this.allStepViews[0];
        return this;
    };

    this.initEvents = function() {
      // here we initiate stage/step events service.. So now we can listen for changes from the bottom.
      stageEvents.init(this.$scope, this.canvas, this);
      stepEvents.init(this.$scope, this.canvas, this);
      return this;
    };

    this.getComponents = function() {

      this.stepIndicator = moveStepRect.getMoveStepRect(this);
      this.stageIndicator = moveStageRect.getMoveStageRect(this);
      this.stageVerticalLine = this.stageIndicator.verticalLine;
      this.stepVerticalLine = this.stepIndicator.verticalLine;
      this.moveDots = this.getMoveDots();
      return this;
    };

    this.addComponentsToStage = function() {

      this.canvas.add(this.stepIndicator);
      this.canvas.add(this.stageIndicator);
      this.canvas.add(this.stageVerticalLine);
      this.canvas.add(this.stepVerticalLine);
      this.canvas.add(this.moveDots);
      return this;
    };

    this.getMoveDots = function() {
      // Move-dots are the dots showing up at the place of a step [top to bottom], when we click on move-step
      var arr = dots.stepStageMoveDots();
      this.imageobjects["move-step-on.png"].setTop(328);
      this.imageobjects["move-step-on.png"].setLeft(-2);
      arr.push(this.imageobjects["move-step-on.png"]);
      
      var properties = {
                      stroke: 'black', strokeWidth: 2, selectable: false,
                      originX: 'left', originY: 'top'
                    };

      var cordinates = [24, 32, 24, 353];
      var lin = Line.create(cordinates, properties);
      arr.push(lin);

      return Group.create(arr, {
        width: 40, left: 16, top: 35, backgroundColor: "white", visible: false
      });
    };
    
    this.loadImages = function() {
      var that = this;
      loadImageService.getImages(this.images).then(function(iData) {
        that.imageobjects = iData;
        that.canvas.fire("imagesLoaded");
      });
      
    };

    return this;
  }
]);
