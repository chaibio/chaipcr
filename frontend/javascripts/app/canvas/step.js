window.ChaiBioTech.ngApp.factory('step', [
  'ExperimentLoader',
  '$rootScope',
  'circle',
  'previouslySelected',
  'stepGraphics',

  function(ExperimentLoader, $rootScope, circle, previouslySelected, stepGraphics) {

    return function(model, parentStage, index) {

      this.model = model;
      this.parentStage = parentStage;
      this.index = index;
      this.canvas = parentStage.canvas;
      this.myWidth = 120;
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
        this.commonFooterImage.set(leftVal).setCoords();
        this.darkFooterImage.set(leftVal).setCoords();
        this.whiteFooterImage.set(leftVal).setCoords();
        this.stepGroup.set(leftVal).setCoords();

        leftVal = {left: this.left + 60};
        this.hitPoint.set(leftVal).setCoords();

        this.ordealStatus = this.ordealStatus + action;
        this.circle.getUniqueId();

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

        this.rampSpeedGroup.setTop(this.circle.top + 25);
        return this;
      };

      this.adjustRampSpeedLeft = function() {

        //this.rampSpeedGroup.setLeft(this.left + 5);
        this.circle.runAlongCircle();
        return this;
      };


      this.manageBorder = function(color) {

        //if(this.borderRight.visible === false) { // Means this is the last step in the stage
        if(this.parentStage.childSteps.length - 1 === this.index) {

          if(this.previousStep) {
            this.previousStep.borderRight.stroke = color;
          } else {
            this.parentStage.border.stroke = color;
          }

          if(this.parentStage.nextStage) {
            this.parentStage.nextStage.border.stroke = color;
          } else {
            this.parentStage.borderRight.stroke = color;
          }

        } else {

          this.borderRight.stroke = color;

          if(this.previousStep) {
            this.previousStep.borderRight.stroke = color;
          } else {
            this.parentStage.border.stroke = color;
          }

        }
      };

      this.manageBorderPrevious = function(color) {

        this.borderRight.setStroke(color);

        if(this.previousStep) {
          this.previousStep.borderRight.setStroke(color);
        }
      };

      this.render = function() {

        this.setLeft();
        stepGraphics.addName.call(this);
        stepGraphics.addBorderRight.call(this);
        this.getUniqueName();
        stepGraphics.rampSpeed.call(this);
        stepGraphics.stepComponents.call(this);
        // Add all those components created.
        this.canvas.add(this.stepGroup);
        this.canvas.add(this.rampSpeedGroup);
        this.canvas.add(this.hitPoint);
        this.addCircle();
      };

      this.showHideFooter = function(visibility) {

        this.darkFooterImage.setVisible(visibility);
        this.whiteFooterImage.setVisible(visibility);
      };

      this.selectStep = function() {

        if(previouslySelected.circle) {
          this.unSelectStep();
        }

        this.manageBorder("black");
        this.showHideFooter(true);
      };

      this.unSelectStep = function() {
        var previouslySelectedStep = previouslySelected.circle.parent;

        previouslySelectedStep.showHideFooter(false);
        previouslySelectedStep.manageBorderPrevious('#ff9f00');
      };
    };
  }
]);
