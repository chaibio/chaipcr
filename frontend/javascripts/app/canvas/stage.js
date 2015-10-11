window.ChaiBioTech.ngApp.factory('stage', [
  'ExperimentLoader',
  '$rootScope',
  'step',
  'previouslySelected',
  'stageGraphics',
  function(ExperimentLoader, $rootScope, step, previouslySelected, stageGraphics) {

    return function(model, stage, allSteps, index, fabricStage, $scope, insert) {

      this.model = model;
      this.index = index;
      this.canvas = stage;
      this.myWidth = (this.model.steps.length * 120);
      this.parent = fabricStage;
      this.childSteps = [];
      this.previousStage = this.nextStage = this.noOfCycles = null;
      this.insertMode = insert;

      this.addNewStep = function(data, currentStep) {

        var width = 120;//(currentStep.index === this.childSteps.length - 1) ? 121 : 120;
        this.myWidth = this.myWidth + width;
        this.stageRect.setWidth(this.myWidth);
        this.roof.setWidth(this.myWidth - 4);

        this.moveAllStepsAndStages();
        // Now insert new step;
        var start = currentStep.index;
        var newStep = new step(data.step, this, start);
        newStep.name = "I am created";
        newStep.render();
        newStep.addImages();
        newStep.ordealStatus = currentStep.ordealStatus;

        this.childSteps.splice(start + 1, 0, newStep);
        this.configureStep(newStep, start);
        this.parent.allStepViews.splice(currentStep.ordealStatus, 0, newStep);

        var circles = this.parent.reDrawCircles();
        this.parent.addRampLinesAndCircles(circles);

        if(this.model.stage_type === "cycling" && this.childSteps.length > 1) {
          this.cycleNo.setVisible(true);
          this.cycleX.setVisible(true);
          this.cycles.setVisible(true);
        }

        $scope.applyValues(newStep.circle);
        newStep.circle.manageClick(true);

        this.parent.setDefaultWidthHeight();
      };

      this.deleteStep = function(data, currentStep) {

        // This methode says what happens in the canvas when a step is deleted
        var width = 120;//(currentStep.index === this.childSteps.length - 1) ? 121 : 120, selected = null;
        this.myWidth = this.myWidth - width;
        this.stageRect.setWidth(this.myWidth);
        this.roof.setWidth(this.myWidth - 4);

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
        this.parent.allStepViews.splice(ordealStatus - 1, 1);

        if(this.childSteps.length > 0) {

          this.configureStepForDelete(currentStep, start);

          if(this.model.stage_type === "cycling" && this.childSteps.length === 1) {
            this.cycleNo.setVisible(false);
            this.cycleX.setVisible(false);
            this.cycles.setVisible(false);
          }

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
          this.updateStageData(-1);

          if(! selected.parentStage.nextStage && this.index !== 0) { //we are exclusively looking for last stage
            selected.parentStage.addBorderRight();
            selected.borderRight.setVisible(false);
          }
        }


        this.moveAllStepsAndStages(true); // true imply call is from delete section;

        var circles = this.parent.reDrawCircles();
        this.parent.addRampLinesAndCircles(circles);

        if(selected.index === this.childSteps.length - 1) {
          // if selected step is the last one in the stage;
          selected.borderRight.setVisible(false);
        }
        $scope.applyValues(selected.circle);
        selected.circle.manageClick();
        //currentStep = null; // we force it to be collected by garbage collector
        this.parent.setDefaultWidthHeight();
        //if(this.childSteps.length === 0) { delete(this); }
      };

      this.deleteStageContents = function() {

        this.canvas.remove(this.stageGroup);
        this.canvas.remove(this.borderRight);

      };

      this.deleteAllStepContents = function(currentStep) {

        this.canvas.remove(currentStep.stepGroup);
        this.canvas.remove(currentStep.rampSpeedGroup);
        this.canvas.remove(currentStep.commonFooterImage);
        this.canvas.remove(currentStep.darkFooterImage);
        this.canvas.remove(currentStep.whiteFooterImage);
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

        currentStage.borderRight.set({left: currentStage.myWidth + currentStage.left + 4 }).setCoords();
      };

      this.updateStageData = function(action) {

        var currentStage = this;

        while(currentStage.nextStage) {
          currentStage.nextStage.index = currentStage.nextStage.index + action;
          //this.stageNo.text = "''"
          var indexNumber = currentStage.nextStage.index + 1;
          var number = (indexNumber < 10) ? "0" + indexNumber : indexNumber;
          currentStage.nextStage.stageNo.text = number.toString();
          currentStage = currentStage.nextStage;
        }

      };
      this.configureStepForDelete = function(newStep, start) {

        this.childSteps.slice(start, this.childSteps.length).forEach(function(thisStep) {

          thisStep.index = thisStep.index - 1;
          this.configureStepName(thisStep);
          thisStep.moveStep(-1);
        }, this);
      };

      this.configureStepName = function(thisStep) {

        if(thisStep.model.name === null) {
          thisStep.stepNameText = "STEP " + (thisStep.index + 1);
          thisStep.stepName.text = thisStep.stepNameText;
        } else {
          thisStep.stepName.text = thisStep.model.name;
        }
      };

      this.configureStep = function(newStep, start) {
        // insert it to all steps, add next and previous , re-render circles;
        for(var j = start + 1; j < this.childSteps.length; j++) {

          var thisStep = this.childSteps[j];
          thisStep.index = thisStep.index + 1;
          this.configureStepName(thisStep);
          thisStep.moveStep(1);
        }

        if(this.childSteps[newStep.index + 1]) {
          newStep.nextStep = this.childSteps[newStep.index + 1];
          newStep.nextStep.previousStep = newStep;
        }

        if(this.childSteps[newStep.index - 1]) {
          newStep.previousStep = this.childSteps[newStep.index - 1];
          newStep.previousStep.nextStep = newStep;
        }

        if(newStep.index === this.childSteps.length - 1) {
          newStep.borderRight.setVisible(false);
          //newStep.borderRight.setFill('#ffb400');
          newStep.previousStep.borderRight.setVisible(true);
        }
      };

      this.getLeft = function() {

        if(this.previousStage) {
          this.left = this.previousStage.left + this.previousStage.myWidth + 4;
        } else {
          this.left = 32;
        }
        return this;
      };

      this.addBorderRight = function() {

        stageGraphics.addBorderRight.call(this);
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
          stepView.borderRight.setVisible(false);
        }
      };

      this.render = function() {

          this.getLeft();
          stageGraphics.addRoof.call(this);
          stageGraphics.borderLeft.call(this);
          stageGraphics.writeMyNo.call(this);
          stageGraphics.writeMyName.call(this);
          stageGraphics.writeNoOfCycles.call(this);
          stageGraphics.createStageRect.call(this);

          var stageContents = [this.stageRect, this.roof, this.border, this.stageNo, this.stageName];

          if(this.model.stage_type === "cycling" && this.model.steps.length > 1) {
            stageContents.push(this.cycleGroup);
          }

          stageGraphics.createStageGroup.apply(this, [stageContents]);
          this.canvas.add(this.stageGroup);
          this.addSteps();
      };

      this.manageBordersOnSelection = function(color) {

        this.border.setStroke(color);

        if(this.nextStage) {
          this.nextStage.border.setStroke(color);
        } else {
          this.borderRight.setStroke(color);
        }
      };

      this.manageFooter = function(visible, color, length) {

        for(var i = 0; i< length; i++) {

          this.childSteps[i].commonFooterImage.setVisible(visible);
          this.childSteps[i].stepName.setFill(color);
        }
      };

      this.changeFillsAndStrokes = function(color)  {

        this.roof.setStroke(color);
        this.stageNo.fill = this.stageName.fill = color;
        this.cycleNo.fill = this.cycleX.fill = this.cycles.fill = color;
      };

      this.selectStage =  function() {

        var length = this.childSteps.length;

        if(previouslySelected.circle) {
          this.unSelectStage();
        }

        this.changeFillsAndStrokes("black");
        this.manageBordersOnSelection("#cc6c00");
        this.manageFooter(true, "black", length);
      };

      this.unSelectStage = function() {

        var previousSelectedStage = previouslySelected.circle.parent.parentStage;
        var previousLength = previousSelectedStage.childSteps.length;

        previousSelectedStage.changeFillsAndStrokes("white");
        previousSelectedStage.manageBordersOnSelection("#ff9f00");
        previousSelectedStage.manageFooter(false, "white", previousLength);
      };
    };

  }
]);
