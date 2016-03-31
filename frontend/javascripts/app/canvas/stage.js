angular.module("canvasApp").factory('stage', [
  'ExperimentLoader',
  '$rootScope',
  'step',
  'previouslySelected',
  'stageGraphics',
  'stepGraphics',
  'constants',
  'circleManager',

  function(ExperimentLoader, $rootScope, step, previouslySelected, stageGraphics, stepGraphics, constants, circleManager) {

    return function(model, stage, allSteps, index, fabricStage, $scope, insert) {

      this.model = model;
      this.index = index;
      this.canvas = stage;
      this.myWidth = (this.model.steps.length * (constants.stepWidth)) + constants.additionalWidth;
      this.parent = fabricStage;
      this.childSteps = [];
      this.previousStage = this.nextStage = this.noOfCycles = null;
      this.insertMode = insert;
      this.shrinked = false;

      this.setNewWidth = function(add) {

        this.myWidth = this.myWidth + add;
        this.stageRect.setWidth(this.myWidth);
        this.stageRect.setCoords();
        this.roof.setWidth(this.myWidth);
      };

      this.shrinkStage = function() {

        console.log("okay Shrinking");
        this.shrinked = true;
        this.myWidth = this.myWidth - 64;
        this.roof.setWidth(this.myWidth).setCoords();
        this.stageRect.setWidth(this.myWidth).setCoords();
        // Befor actually move the step in process movement stage values.
        // Find next stageDots
        // Move all the steps in it to left.
        // Move stage to left ...!!
      };

      this.expand = function() {

        this.myWidth = this.myWidth + 64;
      };

      this.addNewStep = function(data, currentStep) {

        this.setNewWidth(constants.stepWidth);
        this.moveAllStepsAndStages();
        // Now insert new step;
        var start = currentStep.index;
        var newStep = new step(data.step, this, start, $scope);
        newStep.name = "I am created";
        newStep.render();
        newStep.ordealStatus = currentStep.ordealStatus;

        this.childSteps.splice(start + 1, 0, newStep);
        this.model.steps.splice(start + 1, 0, data);
        this.configureStep(newStep, start);
        this.parent.allStepViews.splice(currentStep.ordealStatus, 0, newStep);

        circleManager.addRampLinesAndCircles(circleManager.reDrawCircles());

        $scope.applyValues(newStep.circle);
        newStep.circle.manageClick(true);

        this.parent.setDefaultWidthHeight();
      };

      this.deleteStep = function(data, currentStep) {
        // This methode says what happens in the canvas when a step is deleted
        var selected;
        this.setNewWidth(constants.stepWidth * -1);
        this.deleteAllStepContents(currentStep);
        selected = this.wireNextAndPreviousStep(currentStep, selected);

        var start = currentStep.index;
        var ordealStatus = currentStep.ordealStatus;
        // Delete data from arrays
        this.childSteps.splice(start, 1);
        this.model.steps.splice(start, 1);
        this.parent.allStepViews.splice(ordealStatus - 1, 1);

        if(this.childSteps.length > 0) {
          this.configureStepForDelete(currentStep, start);
        } else { // if all the steps in the stages are deleted, We delete the stage itself.
          this.deleteStageContents();
          this.wireStageNextAndPrevious();

          selected = (this.previousStage) ? this.previousStage.childSteps[this.previousStage.childSteps.length - 1] : this.nextStage.childSteps[0];
          this.parent.allStageViews.splice(this.index, 1);
          selected.parentStage.updateStageData(-1);
        }
        // true imply call is from delete section;
        this.moveAllStepsAndStages(true);
        circleManager.addRampLinesAndCircles(circleManager.reDrawCircles());

        $scope.applyValues(selected.circle);
        selected.circle.manageClick();
        this.parent.setDefaultWidthHeight();
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

      this.wireNextAndPreviousStep = function(currentStep, selected) {

        if(currentStep.previousStep) {
          currentStep.previousStep.nextStep = (currentStep.nextStep) ? currentStep.nextStep : null;
          selected = currentStep.previousStep;
        }

        if(currentStep.nextStep) {
          currentStep.nextStep.previousStep = (currentStep.previousStep) ? currentStep.previousStep: null;
          selected = currentStep.nextStep;
        }
        return selected;
      };

      this.deleteStageContents = function() {

        this.canvas.remove(this.stageGroup);
        this.canvas.remove(this.dots);
        this.canvas.remove(this.borderRight);

      };

      this.deleteAllStepContents = function(currentStep) {

        this.canvas.remove(currentStep.stepGroup);
        this.canvas.remove(currentStep.hitPoint);
        this.canvas.remove(currentStep.closeImage);
        this.canvas.remove(currentStep.dots);
        this.canvas.remove(currentStep.rampSpeedGroup);
        currentStep.circle.removeContents();

      };

      this.moveAllStepsAndStages = function(del) {

        var currentStage = this;

        while(currentStage.nextStage) {

          currentStage.nextStage.getLeft();
          currentStage.nextStage.stageGroup.set({left: currentStage.nextStage.left }).setCoords();
          currentStage.nextStage.dots.set({left: currentStage.nextStage.left + 3}).setCoords();

          var thisStageSteps = currentStage.nextStage.childSteps, stepCount = thisStageSteps.length;

          for(var i = 0; i < stepCount; i++ ) {
            if(del === true) {
              thisStageSteps[i].moveStep(-1, true);
            } else {
              thisStageSteps[i].moveStep(1, true);
            }

          }

          currentStage = currentStage.nextStage;
        }
      };

      this.updateStageData = function(action) {

          if(! this.previousStage && action === -1 && this.index === 1) {
            // This is a special case when very first stage is being deleted and the second stage is selected right away..!
            this.index = this.index + action;
            stageGraphics.stageHeader.call(this);
          }
          var currentStage = this.nextStage;

          while(currentStage) {
            currentStage.index = currentStage.index + action;
            stageGraphics.stageHeader.call(currentStage);
            currentStage = currentStage.nextStage;
          }

      };

      this.configureStepForDelete = function(newStep, start) {

        this.childSteps.slice(0, start).forEach(function(thisStep) {
          thisStep.configureStepName();
        }, this);

        this.childSteps.slice(start, this.childSteps.length).forEach(function(thisStep) {

          thisStep.index = thisStep.index - 1;
          thisStep.configureStepName();
          thisStep.moveStep(-1, true);
        }, this);
      };

      this.configureStep = function(newStep, start) {
        // insert it to all steps, add next and previous , re-render circles;
        for(var j = 0; j < this.childSteps.length; j++) {

          var thisStep = this.childSteps[j];
          if(j >= start + 1) {
            thisStep.index = thisStep.index + 1;
            thisStep.configureStepName();
            thisStep.moveStep(1, true);
          } else {
            stepGraphics.numberingValue.call(thisStep);
          }
        }

        if(this.childSteps[newStep.index + 1]) {
          newStep.nextStep = this.childSteps[newStep.index + 1];
          newStep.nextStep.previousStep = newStep;
        }

        if(this.childSteps[newStep.index - 1]) {
          newStep.previousStep = this.childSteps[newStep.index - 1];
          newStep.previousStep.nextStep = newStep;
        }
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

        var stepView, that = this;
        this.childSteps = [];

        // We use reduce here so that Linking is easy here, because reduce retain the previous value which we return.
        this.model.steps.reduce(function(tempStep, STEP, stepIndex) {

          stepView = new step(STEP.step, that, stepIndex, $scope);

          if(tempStep) {
            tempStep.nextStep = stepView;
            stepView.previousStep = tempStep;
          }

          that.childSteps.push(stepView);

          if(! that.insertMode) {
            allSteps.push(stepView);
            stepView.ordealStatus = allSteps.length;
            stepView.render();
          }

          return stepView;
        }, null);
      };

      this.render = function() {

          this.getLeft();
          stageGraphics.addRoof.call(this);
          stageGraphics.borderLeft.call(this);
          stageGraphics.writeMyName.call(this);
          stageGraphics.createStageRect.call(this);
          stageGraphics.dotsOnStage.call(this);
          stageGraphics.stageHeader.call(this);

          var stageContents = [this.stageRect, this.stageNameGroup, this.roof, this.border]; //this.dots
          stageGraphics.createStageGroup.apply(this, [stageContents]);
          this.canvas.add(this.stageGroup);
          this.canvas.add(this.dots);
          this.addSteps();
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
            obj.setFill(color);
          });
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

      this.unSelectStage = function() {

        var previousSelectedStage = previouslySelected.circle.parent.parentStage;

        previousSelectedStage.changeFillsAndStrokes("white", 2);
        previousSelectedStage.manageBordersOnSelection("#ff9f00");
      };
    };

  }
]);
