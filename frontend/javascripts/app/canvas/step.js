window.ChaiBioTech.ngApp.factory('step', [
  'ExperimentLoader',
  '$rootScope',
  'circle',
  'previouslySelected',

  function(ExperimentLoader, $rootScope, circle, previouslySelected) {

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

        this.commonFooterImage = can.applyPropertyToImages($.extend({}, can.imageobjects["common-step.png"]), this);
        can.canvas.add(this.commonFooterImage);

        this.darkFooterImage = can.applyPropertyToImages($.extend({}, can.imageobjects["black-footer.png"]), this);
        can.canvas.add(this.darkFooterImage);

        this.whiteFooterImage = can.applyPropertyToImages($.extend({}, can.imageobjects["orange-footer.png"]), this, 'moveStepImage');
        this.whiteFooterImage.top = 365;
        this.whiteFooterImage.left = this.left;
        can.canvas.add(this.whiteFooterImage);

        this.circle.gatherDataImage = $.extend({}, can.imageobjects["gather-data.png"]);
        this.circle.gatherDataImage.originX = "center";
        this.circle.gatherDataImage.originY = "center";

        this.circle.gatherDataImageOnMoving = $.extend({}, can.imageobjects["gather-data-image.png"]);
        this.circle.gatherDataImageOnMoving.originX = "center";
        this.circle.gatherDataImageOnMoving.originY = "center";

        this.circle.gatherDataImageMiddle = $.extend({}, can.imageobjects["gather-data.png"]);
        this.circle.gatherDataImageMiddle.originX = "center";
        this.circle.gatherDataImageMiddle.originY = "center";
        this.circle.gatherDataImageMiddle.setVisible(false);

      };

      this.moveStep = function(action) {

        this.setLeft();
        this.getUniqueName();
        var leftVal = {left: this.left};
        this.commonFooterImage.set(leftVal).setCoords();
        this.darkFooterImage.set(leftVal).setCoords();
        this.whiteFooterImage.set(leftVal).setCoords();
        this.stepGroup.set(leftVal).setCoords();

        this.ordealStatus = this.ordealStatus + action;
        this.circle.getUniqueId();

      };

      this.addName = function() {

        var stepName = (this.model.name) ? (this.model.name).toUpperCase() : "STEP " +(this.index + 1);
        this.stepNameText = stepName;
        this.stepName = new fabric.Text(stepName, {
            fill: 'white',  fontSize: 9,  top : -4,  left: 3,  fontFamily: "Open Sans",  selectable: false,
            originX: 'left', originY: 'top'
          }
        );

        return this;
      };

      this.addBorderRight = function() {

        this.borderRight = new fabric.Line([0, 0, 0, 342], {
            stroke: '#ff9f00',  left: (this.myWidth - 2),  top: 7, strokeWidth: 1, selectable: false,
            originX: 'left', originY: 'top'
          }
        );

        return this;
      };

      this.gatherDuringStep = function() {

        this.gatherDataDuringStep = !(this.gatherDataDuringStep);
        this.model.gatherDuringStep(this.gatherDataDuringStep);
        this.circle.showHideGatherData(this.gatherDataDuringStep);
        this.canvas.renderAll();
      };

      this.gatherDuringRamp = function() {

        if(this.parentStage.previousStage || this.previousStep) {
          this.gatherDataDuringRamp = !(this.gatherDataDuringRamp);
          this.model.gatherDataDuringRamp(this.gatherDataDuringRamp);
          this.circle.gatherDataGroup.visible = this.gatherDataDuringRamp;
          this.canvas.renderAll();
        }
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

        this.rampSpeedGroup.setTop(this.circle.top + 24);
        this.rampSpeedGroup.setLeft(this.left + 10);
      };

      this.adjustRampSpeedLeft = function() {
        this.rampSpeedGroup.setLeft(this.left + 10);
        return this;
      };

      this.rampSpeed = function() {

        this.rampSpeedNumber = parseFloat(this.model.ramp.rate);

        this.rampSpeedText = new fabric.Text(String(this.rampSpeedNumber)+ "º C/s", {
            fill: 'black',  fontSize: 14, fontWeight: "bold", fontFamily: "Open Sans",  originX: 'left',  originY: 'top'
          }
        );

        this.underLine = new fabric.Line([0, 0, this.rampSpeedText.width, 0], {
            stroke: "#ffde00",  strokeWidth: 2, originX: 'left',  originY: 'top', top: 13,  left: 0
          }
        );

        this.rampSpeedGroup = new fabric.Group([
              this.rampSpeedText, this.underLine
            ], {
                selectable: true, hasControls: true,  originX: 'left',  originY: 'top', top : 0,  left: this.left + 10
              }
        );

        if(this.rampSpeedNumber <= 0) {
          this.rampSpeedGroup.setVisible(false);
        }

        return this;
      };

      this.manageBorder = function(color) {
        //console.log(this.parentStage.childSteps.length -1 , this.index, this.uniqueName);
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

        this.setLeft()
          .addName()
          .addBorderRight()
          .getUniqueName()
          .rampSpeed();

        // We create a hitPoint so that we know if the move step actually over the particular step.
        this.hitPoint = new fabric.Circle({
          radius: 3, fill: '', left: this.left + 110, top: 310, selectable: false, name: "hitPoint"
        });

        this.stepRect = new fabric.Rect({
            fill: '#ffb400',  width: this.myWidth,  height: 340,  selectable: false,  name: "step", me: this
          }
        );

        this.stepGroup = new fabric.Group([this.stepRect, this.stepName, this.borderRight], {
          left: this.left || 32,  top: 44,  selectable: false,  hasControls: false,
          hasBoarders: false, name: "stepGroup",  me: this, originX: 'left', originY: 'top'
        });

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
