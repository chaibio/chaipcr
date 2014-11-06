ChaiBioTech.app.Views = ChaiBioTech.app.Views || {};
ChaiBioTech.app.selectedStep = null;

ChaiBioTech.app.Views.fabricStep = function(model, parentStage, index) {

  this.model = model;
  this.parentStage = parentStage;
  this.index = index;
  this.canvas = parentStage.canvas;
  this.myWidth = 120;
  this.nextStep = null;
  this.previousStep = null;
  this.gatherDataDuringStep = this.model.get("step")["collect_data"];
  this.gatherDataDuringRamp = this.model.get("step").ramp["collect_data"];
  this.holdDuration = null;

  this.setLeft = function() {

    this.left = this.parentStage.left + 1 + (parseInt(this.index) * this.myWidth);
    return this;
  };

  this.addName = function() {

    var stepName = (this.model.get("step").name).toUpperCase();

    this.stepName = new fabric.IText(stepName, {
      fill: 'white',
      fontSize: 9,
      top : 45,
      left: this.left + 3,
      fontFamily: "Open Sans",
      selectable: true,
      lockRotation: true,
      lockScalingX: true,
      lockScalingY: true,
      lockMovementX: true,
      lockMovementY: true,
      hasControls: false
    });

    return this;
  };

  this.updateStepName = function() {

    this.stepName.text = (this.updatedStepName).toUpperCase();
    this.canvas.renderAll();
  };

  this.addBorderRight = function() {

    this.borderRight = new fabric.Line([0, 0, 0, 342], {
      stroke: '#ff9f00',
      left: this.left + (this.myWidth - 2),
      top: 60,
      strokeWidth: 1,
      selectable: false
    });

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

    this.circle = new ChaiBioTech.app.Views.fabricCircle(this.model, this);
    this.circle.render();
  };

  this.getUniqueName = function() {

    var name = this.stepName.text + this.parentStage.stageNo.text + "step";
    
    this.uniqueName = name;
    return this;
  };

  this.showHideRamp = function() {
    this.rampSpeedText.text = String(this.rampSpeedNumber + "º C/s");

    if(this.rampSpeedNumber <= 0) {
      this.rampSpeedGroup.setVisible(false);
    } else {
      this.rampSpeedGroup.setVisible(true);
      this.canvas.renderAll();
      this.underLine.width = this.rampSpeedText.width;
      this.rampSpeedGroup.left = this.left + ((120 - this.rampSpeedText.width) / 2)
    }

    this.canvas.renderAll();
  };

  this.rampSpeed = function() {

    this.rampSpeedNumber = this.rampSpeedNumber || parseFloat(this.model.get("step").ramp.rate);

    this.rampSpeedText = new fabric.Text(String(this.rampSpeedNumber)+ "º C/s", {
      fill: 'black',
      fontSize: 12,
      fontWeight: "bold",
      fontFamily: "Open Sans",
      originX: 'left',
      originY: 'top'
    });

    this.underLine = new fabric.Line([0, 0, this.rampSpeedText.width, 0], {
      stroke: "#ffde00",
      strokeWidth: 2,
      originX: 'left',
      originY: 'top',
      top: 14,
      left: 0
    });

    this.rampSpeedGroup = new fabric.Group([this.rampSpeedText, this.underLine], {
      originX: 'center',
      originY: 'center',
      selectable: false,
      hasControls: false,
      originX: 'left',
      originY: 'top',
      top : 100,
      left: this.left + ((120 - this.rampSpeedText.width) / 2)
    });

    if(this.rampSpeedNumber <= 0) {
      this.rampSpeedGroup.setVisible(false);
    }

    return this;
  };

  this.manageBorder = function(color) {

    if(this.borderRight.visible === false) { // Means this is the last step in the stage

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

    this.setLeft().addName().addBorderRight().getUniqueName().rampSpeed();

    this.stepRect = new fabric.Rect({
      left: this.left || 30,
      top: 64,
      fill: '#ffb400',
      width: this.myWidth,
      height: 340,
      selectable: false,
      name: "step",
      me: this
    });

    this.canvas.add(this.stepRect, this.stepName, this.rampSpeedGroup, this.borderRight);
    this.addCircle();
  };

  this.showHideFooter = function(visibility) {

    this.darkFooterImage.setVisible(visibility);
    this.whiteFooterImage.setVisible(visibility);
  };

  this.selectStep = function(evt) {

    if(ChaiBioTech.app.selectedStep) {
      var previouslySelected = ChaiBioTech.app.selectedStep;

      previouslySelected.showHideFooter(false);
      previouslySelected.manageBorderPrevious('#ff9f00');
    }

    ChaiBioTech.app.selectedStep = this;
    this.manageBorder("black");
    this.showHideFooter(true);
  }

  return this;
}
