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

angular.module("canvasApp").factory('stage', [
  'step',
  'previouslySelected',
  'stageGraphics',
  'constants',
  'correctNumberingService',
  'addStepService',
  'deleteStepService',
  'moveStageToSides',
  function(step, previouslySelected, stageGraphics, constants, correctNumberingService, addStepService, deleteStepService, moveStageToSides) {

    /*
      @model has all the data points related to stage
      @kanvas , this object is canvas factory, which is returned from canvas.js
      @index index of the stage
      @insert, true if we are inserting the stage, whe we move/add a stage. false when we load the stages for the first time
      @scope, actual angular $scope object. Which we passed to use within fabric.
    */

    return function(model, kanvas, index, insert, $scope) {
      
      this.model = model;
      this.index = index;
      this.canvas = kanvas.canvas;
      this.myWidth = (this.model.steps.length * (constants.stepWidth)) + constants.additionalWidth;
      this.parent = kanvas;
      this.childSteps = [];
      this.previousStage = this.nextStage = this.noOfCycles = null;
      this.insertMode = insert;
      this.shrinked = false;
      this.shadowText = "0px 1px 2px rgba(0, 0, 0, 0.5)";
      this.visualComponents = {};
      this.stageMovedDirection = null;
      this.shortStageName = false;
      this.shrinkedStage = false;
      this.sourceStage = false; // Says if we had clicked to move a step from this stage
      this.moveStepAction = null; // This holds the value of del, which is the first parameter to moveStep(Action, callSetLeft)

      this.setNewWidth = function(add) {

        this.myWidth = this.myWidth + add;
        this.setWidth();
      };

      this.updateWidth = function() {
        
        this.myWidth = (this.model.steps.length * (constants.stepWidth)) + constants.additionalWidth;
        this.setWidth();
      };

      this.setWidth = function() {

        this.stageRect.setWidth(this.myWidth);
        this.stageRect.setCoords();
        this.roof.setWidth(this.myWidth);
      };

      this.collapseStage = function() {
        
        this.childSteps.forEach(this.deleteAllStepContents, this);
        this.deleteStageContents();
        // Bring other stages closer
        if(this.nextStage) {
          var width = this.myWidth;
          // This is a trick, when we moveAllStepsAndStages we calculate the placing with myWidth, please refer getLeft() method
          this.myWidth = constants.moveStageInitialSpace; // 23
          this.moveAllStepsAndStages(true);
          this.myWidth = width;
        }
      };

      this.addNewStep = function(data, currentStep) {
        
        addStepService.addNewStep(this, data, currentStep, $scope);
        return ;
        
      };

      this.deleteStep = function(data, currentStep) {
        
        deleteStepService.deleteStep(this, currentStep, $scope);
        return;
      };

      this.wireStageNextAndPrevious = function() {

        if(this.previousStage) {
          this.previousStage.nextStage = (this.nextStage) ? this.nextStage : null;
        } else {
          this.nextStage.previousStage = null;
        }

        if(this.nextStage) {
          this.nextStage.previousStage = (this.previousStage) ? this.previousStage : null;
        } else {
          this.previousStage.nextStage = null;
        }
      };

      this.deleteStageContents = function() {

        for(var component in this.visualComponents) {
          
          if(component === "dots") {
            //var items = this.dots._objects;
            this.canvas.remove(this.dots);
            this.dots.forEachObject(function(O) {
              this.canvas.remove(O);
              this.dots.removeWithUpdate(O);
            }, this);
            this.canvas.discardActiveGroup();
            continue;
          }
          this.canvas.remove(this.visualComponents[component]);
        }
      };

      this.deleteFromStage = function(index, ordealStatus) {
        
        this.deleteAllStepContents(this.childSteps[index]);
        this.childSteps[index].wireNextAndPreviousStep(this.childSteps[index]);
        this.childSteps.splice(index, 1);
        this.model.steps.splice(index, 1);
        this.parent.allStepViews.splice(ordealStatus - 1, 1);
        
        correctNumberingService.correctNumbering();
        console.log("From step", this.childSteps.length);
      };

      this.deleteAllStepContents = function(currentStep) {
        currentStep.deleteAllStepContents();
      };

      this.moveIndividualStageAndContents = function(stage, del) {

        stage.getLeft();
        stage.stageGroup.setLeft(stage.left);
        stage.stageGroup.setCoords();
        stage.dots.setLeft(stage.left + 3);
        stage.dots.setCoords();
        //stage.myWidth = (stage.model.steps.length * (constants.stepWidth)) + constants.additionalWidth;
        this.moveStepAction = (del === true) ? -1 : 1; 
        stage.childSteps.forEach(this.manageMovingChildsteps, this);

      };

      this.manageMovingChildsteps = function(childStep) {

        childStep.moveStep(this.moveStepAction, true);
        childStep.circle.moveCircleWithStep();
      };

      this.moveAllStepsAndStages = function(del) {

        var currentStage = this;
        while(currentStage) {
          this.moveIndividualStageAndContents(currentStage, del);
          currentStage = currentStage.nextStage;
        }
      };

      this.updateStageData = function(action) {

          if(! this.previousStage && action === -1 && this.index === 1) {
            // This is a special case when very first stage is being deleted and the 
            // second stage is selected right away..!
            this.index = this.index + action;
            this.stageHeader();
          }
          var currentStage = this.nextStage;

          while(currentStage) {
            currentStage.index = currentStage.index + action;
            currentStage.stageHeader();
            currentStage = currentStage.nextStage;
          }

      };

      this.squeezeStage = function(step) {
          
        this.deleteFromStage(step.index, step.ordealStatus);
        if(this.childSteps.length === 0) {
          this.wireStageNextAndPrevious();
          selected = (this.previousStage) ? this.previousStage.childSteps[this.previousStage.childSteps.length - 1] : step.parentStage.nextStage.childSteps[0];
          this.parent.allStageViews.splice(step.parentStage.index, 1);
          selected.parentStage.updateStageData(-1);
        }    
      };
      
      this.shortenStageName = function() {
        var text = this.stageName.text.substr(0, 8);
        this.stageName.setText(text);
        this.shortStageName = true;
      };

      this.getLeft = function() {

        if(this.previousStage) {
          this.left = this.previousStage.left + this.previousStage.myWidth + constants.newStageOffset;
        } else {
          this.left = 33;
        }
        return this;
      };

      this.addSteps = function() {

        var that = this;
        this.childSteps = [];
        // We use reduce here so that Linking is easy here, 
        // because reduce retain the previous value which we return.
        this.model.steps.reduce(function(tempStep, STEP, stepIndex) {
          return that.configureStepOnCreate(tempStep, STEP, stepIndex);
        }, null);
      };

      this.configureStepOnCreate  = function(tempStep, STEP, stepIndex) {

        var stepView = new step(STEP.step, this, stepIndex, $scope);

          if(tempStep) {
            tempStep.nextStep = stepView;
            stepView.previousStep = tempStep;
          }

          this.childSteps.push(stepView);

          if(! this.insertMode) {
            this.parent.allStepViews.push(stepView);
            stepView.ordealStatus = this.parent.allStepViews.length;
            stepView.render();
          }
          return stepView;
      };

      this.stageHeader = function() {
        
        if(this.stageName) {
          var index = parseInt(this.index) + 1;
          var stageName = (this.model.name).toUpperCase().replace("STAGE", "");
          var text = (stageName).trim();
          this.stageCaption.setText("STAGE " + index + ": " );

          if(this.model.stage_type === "cycling") {
            var noOfCycles = this.model.num_cycles;
            noOfCycles = String(noOfCycles);
            text = text + ", " + noOfCycles + "x";
          }

          this.stageName.setText(text);
          this.stageName.setLeft(this.stageCaption.left + this.stageCaption.width);

          if(this.parent.editStageStatus && this.childSteps.length === 1) {
            this.shortenStageName();
          } else {
            this.shortStageName = false;
          }
        }
      };

      this.adjustHeader = function() {
        
        this.stageName.setVisible(false);
        this.dots.setVisible(false);
        this.stageCaption.setLeft(this.stageCaption.left - 24);
        this.stageCaption.setCoords();
        this.canvas.sendToBack(this.stageGroup);
      };

      this.render = function() {

          this.getLeft();
          stageGraphics.addRoof.call(this);
          stageGraphics.borderLeft.call(this);
          stageGraphics.writeMyName.call(this);
          stageGraphics.createStageRect.call(this);
          stageGraphics.dotsOnStage.call(this);
          this.stageHeader();
          stageGraphics.createStageGroup.call(this);

          this.visualComponents = {
            'stageGroup': this.stageGroup,
            'dots': this.dots,
            'borderRight': this.borderRight
          };

          this.canvas.add(this.stageGroup);
          this.canvas.add(this.dots);

          this.setShadows();
          this.addSteps();
      };

      this.setShadows = function() {

        this.stageName.setShadow(this.shadowText);
        this.stageCaption.setShadow(this.shadowText);
      };

      this.manageBordersOnSelection = function(color) {

        if(this.childSteps[this.childSteps.length - 1]) {
          this.border.setStroke(color);
          this.childSteps[this.childSteps.length - 1].borderRight.setStroke(color);
          this.childSteps[this.childSteps.length - 1].borderRight.setStrokeWidth(2);
        }
      };

      this.changeFillsAndStrokes = function(color, strokeWidth)  {

        this.roof.setStroke(color);
        this.roof.setStrokeWidth(strokeWidth);

        if(this.parent.editStageStatus) {
          this.dots.forEachObject(function(obj) {
            if(obj.name === "stageDot") {
              obj.setFill(color);
            }
          });
          this.canvas.bringToFront(this.dots);
          this.dots.setCoords();
        }

        this.stageName.setFill(color);
        this.stageCaption.setFill(color);
      };

      this.selectStage =  function() {

        if(previouslySelected.circle) {
          this.unSelectStage();
        }

        this.changeFillsAndStrokes("black", 4);
        this.manageBordersOnSelection("#cc6c00");
      };

      this.removeFromStagesArray = function() {

        this.parent.allStageViews.splice(this.index, 1);

        var length = this.parent.allStageViews.length;

        for( i = this.index;  i < length; i++) {
          this.parent.allStageViews[i].index = i;
        }
      };

      this.unSelectStage = function() {

        var previousSelectedStage = previouslySelected.circle.parent.parentStage;
        previousSelectedStage.changeFillsAndStrokes("white", 2);
        previousSelectedStage.manageBordersOnSelection("#ff9f00");
      };
    };

  }
]);
