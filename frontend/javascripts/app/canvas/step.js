window.ChaiBioTech.ngApp.factory('step', [
  'ExperimentLoader',
  '$rootScope',
  'circle',
  'previouslySelected',
  'stepGraphics',
  'constants',

  function(ExperimentLoader, $rootScope, circle, previouslySelected, stepGraphics, constants) {

    return function(model, parentStage, index) {

      this.model = model;
      this.parentStage = parentStage;
      this.index = index;
      this.canvas = parentStage.canvas;
      this.myWidth = constants.stepWidth;
      this.nextStep = null;
      this.previousStep = null;
      this.gatherDataDuringStep = this.model.collect_data;
      this.gatherDataDuringRamp = this.model.ramp.collect_data;

      this.setLeft = function() {

        this.left = this.parentStage.left + 3 + (parseInt(this.index) * this.myWidth);
        return this;
      };

      this.addImages = function() {

        var can = this.parentStage.parent;
        can.addImagesC(this);
        this.circle.addImages();
      };

      this.moveStep = function(action) {

        this.setLeft();
        this.getUniqueName();
        var leftVal = {left: this.left};
        //this.commonFooterImage.set(leftVal).setCoords();
        //this.darkFooterImage.set(leftVal).setCoords();
        //this.whiteFooterImage.set(leftVal).setCoords();
        this.stepGroup.set(leftVal).setCoords();

        leftVal = {left: this.left + (this.myWidth / 2)};
        this.hitPoint.set(leftVal).setCoords();

        leftVal = {left: this.left + 108};
        this.delGroup.set(leftVal).setCoords();

        leftVal = {left: this.left + 16};
        this.dots.set(leftVal).setCoords();

        this.ordealStatus = this.ordealStatus + action;
        this.circle.getUniqueId();

      };

      this.configureStepName = function(thisStep) {

        if(this.model.name === null) {
          this.stepNameText = "Step " + (this.index + 1);
          this.stepName.text = this.stepNameText;
        } else {
          this.stepName.text = this.model.name;
        }
        stepGraphics.numberingValue.call(this);
      };

      this.addCircle = function() {

        this.circle = new circle(this.model, this);
        this.circle.getLeft()
          .getTop()
          .getUniqueId()
          .addImages()
          .render();
      };

      this.getUniqueName = function() {

        this.uniqueName = this.model.id + this.parentStage.stageNo.text + "step";
        return this;
      };

      this.showHideRamp = function() {

        this.rampSpeedText.text = String(this.model.ramp.rate + "º C/s");
        var rampRate = Number(this.model.ramp.rate);
        if(rampRate <= 0 || ! rampRate) {
          this.rampSpeedGroup.setVisible(false);
        } else {
          this.rampSpeedGroup.setVisible(true);
          this.underLine.setWidth(this.rampSpeedText.width);
        }

        this.canvas.renderAll();
      };

      this.adjustRampSpeedPlacing = function() {

        this.rampSpeedGroup.setTop(this.circle.top + 20);
        return this;
      };

      this.adjustRampSpeedLeft = function() {

        //this.rampSpeedGroup.setLeft(this.left + 5);
        this.circle.runAlongCircle();
        return this;
      };


      this.manageBorder = function(color) {

        //if(this.borderRight.visible === false) { // Means this is the last step in the stage
        this.borderRight.setStroke(color);
        this.borderRight.setStrokeWidth(2);
        if(this.previousStep) {
          this.previousStep.borderRight.setStroke(color);
          this.previousStep.borderRight.setStrokeWidth(2);
        } else {
          this.parentStage.border.setStroke(color);
        }
        /*if(this.parentStage.childSteps.length - 1 === this.index) {

          if(this.previousStep) {
            this.previousStep.borderRight.stroke = color;
          } else {
            this.parentStage.border.stroke = color;
          }

        } else {

          this.borderRight.stroke = color;

          if(this.previousStep) {
            this.previousStep.borderRight.stroke = color;
          } else {
            this.parentStage.border.stroke = color;
          }

        }*/
      };

      this.manageBorderPrevious = function(color, currentStep) {

        if(this.parentStage.childSteps.length - 1 === this.index && this.parentStage.index === currentStep.parentStage.index) {
          //console.log("okay hitt", currentStep.parentStage);
          this.borderRight.setStroke("#cc6c00");
          this.borderRight.setStrokeWidth(2);
        } else {
          this.borderRight.setStroke(color);
          this.borderRight.setStrokeWidth(1);
        }

        if(this.previousStep) {
          this.previousStep.borderRight.setStroke(color);
          this.previousStep.borderRight.setStrokeWidth(1);
        }
      };

      this.render = function() {

        this.setLeft();
        stepGraphics.addName.call(this);
        stepGraphics.addBorderRight.call(this);
        this.getUniqueName();
        stepGraphics.rampSpeed.call(this);
        stepGraphics.initNumberText.call(this);
        stepGraphics.initAutoDelta.call(this);
        stepGraphics.autoDeltaDetails.call(this);
        stepGraphics.numberingValue.call(this);
        stepGraphics.deleteButton.call(this);
        stepGraphics.stepFooter.call(this);
        stepGraphics.stepComponents.call(this);

        // Add all those components created.
        this.canvas.add(this.stepGroup);
        this.canvas.add(this.rampSpeedGroup);
        this.canvas.add(this.hitPoint);
        this.canvas.add(this.delGroup);
        this.canvas.add(this.dots);
        this.addCircle();
      };

      this.showHideFooter = function(visibility, color) {

        this.dots.forEachObject(function(obj) {
          obj.setFill(color);
        });
      };

      this.selectStep = function() {

        if(previouslySelected.circle) {
          this.unSelectStep();
        }

        this.manageBorder("black");
        if(this.parentStage.parent.editStageStatus) {
          this.showHideFooter(true, "black");
        }

        this.stepName.setFill("black");
        this.numberingText.setFill("black");
      };

      this.unSelectStep = function() {
        var previouslySelectedStep = previouslySelected.circle.parent;

        if(this.parentStage.parent.editStageStatus) {
          previouslySelectedStep.showHideFooter(false, "white");
        }

        previouslySelectedStep.manageBorderPrevious('#ff9f00', this);
        previouslySelectedStep.stepName.setFill("white");
        previouslySelectedStep.numberingText.setFill("white");
      };
    };
  }
]);
