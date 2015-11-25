window.ChaiBioTech.ngApp.factory('stage', [
  'ExperimentLoader',
  '$rootScope',
  'step',
  'previouslySelected',
  'stageGraphics',
  'stepGraphics',
  'constants',

  function(ExperimentLoader, $rootScope, step, previouslySelected, stageGraphics, stepGraphics, constants) {

    return function(model, stage, allSteps, index, fabricStage, $scope, insert) {

      this.model = model;
      this.index = index;
      this.canvas = stage;
      this.myWidth = (this.model.steps.length * (constants.stepWidth)) + constants.additionalWidth;
      this.parent = fabricStage;
      this.childSteps = [];
      this.previousStage = this.nextStage = this.noOfCycles = null;
      this.insertMode = insert;

      this.addNewStep = function(data, currentStep) {

        var width = constants.stepWidth;
        this.myWidth = this.myWidth + width;
        this.stageRect.setWidth(this.myWidth);
        this.stageRect.setCoords();
        this.roof.setWidth(this.myWidth);

        this.moveAllStepsAndStages();
        // Now insert new step;
        var start = currentStep.index;
        var newStep = new step(data.step, this, start);
        newStep.name = "I am created";
        newStep.render();
        newStep.ordealStatus = currentStep.ordealStatus;

        this.childSteps.splice(start + 1, 0, newStep);
        this.model.steps.splice(start + 1, 0, data);
        this.configureStep(newStep, start);
        this.parent.allStepViews.splice(currentStep.ordealStatus, 0, newStep);

        var circles = this.parent.reDrawCircles();
        this.parent.addRampLinesAndCircles(circles);

        $scope.applyValues(newStep.circle);
        newStep.circle.manageClick(true);

        this.parent.setDefaultWidthHeight();
      };

      this.deleteStep = function(data, currentStep) {

        // This methode says what happens in the canvas when a step is deleted
        var width = constants.stepWidth;
        this.myWidth = this.myWidth - width;
        this.stageRect.setWidth(this.myWidth);
        this.roof.setWidth(this.myWidth);

        this.deleteAllStepContents(currentStep);

        if(currentStep.previousStep) {
          currentStep.previousStep.nextStep = (currentStep.nextStep) ? currentStep.nextStep : null;
          selected = currentStep.previousStep;
        }

        if(currentStep.nextStep) {
          currentStep.nextStep.previousStep = (currentStep.previousStep) ? currentStep.previousStep: null;
          selected = currentStep.nextStep;
        }

        var start = currentStep.index;
        var ordealStatus = currentStep.ordealStatus;
        this.childSteps.splice(start, 1);
        this.model.steps.splice(start, 1);

        this.parent.allStepViews.splice(ordealStatus - 1, 1);

        if(this.childSteps.length > 0) {

          this.configureStepForDelete(currentStep, start);

        } else { // if all the steps in the stages are deleted, We delete the stage itself.

          this.deleteStageContents();

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

          selected = (this.previousStage) ? this.previousStage.childSteps[this.previousStage.childSteps.length - 1] : this.nextStage.childSteps[0];
          this.parent.allStageViews.splice(this.index, 1);
          selected.parentStage.updateStageData(-1);
        }


        this.moveAllStepsAndStages(true); // true imply call is from delete section;

        var circles = this.parent.reDrawCircles();
        this.parent.addRampLinesAndCircles(circles);

        $scope.applyValues(selected.circle);
        selected.circle.manageClick();
        this.parent.setDefaultWidthHeight();
      };

      this.deleteStageContents = function() {

        this.canvas.remove(this.stageGroup);
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

          var thisStageSteps = currentStage.nextStage.childSteps, stepCount = thisStageSteps.length;

          for(var i = 0; i < stepCount; i++ ) {
            if(del === true) {
              thisStageSteps[i].moveStep(-1);
            } else {
              thisStageSteps[i].moveStep(1);
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

          //thisStep.index = thisStep.index - 1;
          thisStep.configureStepName();
          //thisStep.moveStep(-1);
        }, this);

        this.childSteps.slice(start, this.childSteps.length).forEach(function(thisStep) {

          thisStep.index = thisStep.index - 1;
          thisStep.configureStepName();
          thisStep.moveStep(-1);
        }, this);
      };

      this.configureStep = function(newStep, start) {
        // insert it to all steps, add next and previous , re-render circles;
        for(var j = 0; j < this.childSteps.length; j++) {

          var thisStep = this.childSteps[j];
          if(j >= start + 1) {
            thisStep.index = thisStep.index + 1;
            thisStep.configureStepName();
            thisStep.moveStep(1);
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

          stepView = new step(STEP.step, that, stepIndex);

          if(tempStep) {
            tempStep.nextStep = stepView;
            stepView.previousStep = tempStep;
          }

          that.childSteps.push(stepView);

          if(that.insertMode === false) {
            allSteps.push(stepView);
            stepView.ordealStatus = allSteps.length;
            stepView.render();
          }

          return stepView;
        }, null);

        if(this.insertMode === false) {
          stepView.borderRight.setVisible(true);
        }
      };

      this.render = function() {

          this.getLeft();
          stageGraphics.addRoof.call(this);
          stageGraphics.borderLeft.call(this);
          stageGraphics.writeMyName.call(this);
          stageGraphics.createStageRect.call(this);
          stageGraphics.dotsOnStage.call(this);
          stageGraphics.stageHeader.call(this);

          var stageContents = [this.stageRect, this.stageNameGroup, this.roof, this.border, this.dots]; //this.dots
          stageGraphics.createStageGroup.apply(this, [stageContents]);
          this.canvas.add(this.stageGroup);
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
