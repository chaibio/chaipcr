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
  
  this.setLeft = function() {
    this.left = this.parentStage.left + 1 + (parseInt(this.index) * this.myWidth);
  }

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
  }

  this.addBorderRight = function() {
    this.borderRight = new fabric.Line([0, 0, 0, 342], {
      stroke: '#ff9f00',
      left: this.left + (this.myWidth - 2),
      top: 60,
      strokeWidth: 1,
      selectable: false
    });
  }

  this.gatherDuringStep = function() {
    this.gatherDataDuringStep = !(this.gatherDataDuringStep);
    this.model.gatherDuringStep(this.gatherDataDuringStep);
    this.circle.showHideGatherData(this.gatherDataDuringStep);
    this.canvas.renderAll();
  }

  this.gatherDuringRamp = function() {
    if(this.parentStage.previousStage || this.previousStep) {
      this.gatherDataDuringRamp = !(this.gatherDataDuringRamp);
      this.model.gatherDataDuringRamp(this.gatherDataDuringRamp);
      this.circle.gatherDataGroup.visible = this.gatherDataDuringRamp;
      this.canvas.renderAll();
    }
  }

  this.addCircle = function() {
    this.circle = new ChaiBioTech.app.Views.fabricCircle(this.model, this);
    this.circle.render();
  }

  this.getUniqueName = function() {
    var name = this.stepName.text + this.parentStage.stageNo.text + "step";
    this.uniqueName = name;
  }

  this.rampSpeed = function() {
    this.rampSpeedNumber = parseFloat(this.model.get("step").ramp.rate);
    // Move this to different files
    this.rampSpeedText = new fabric.Text(String(this.rampSpeedNumber)+ "º C/s", {
      fill: 'black',
      fontSize: 16,
      fontWeight: "bold",
      fontFamily: "Open Sans"
    });

    this.underLine = new fabric.Line([0, 0, this.rampSpeedText.width, 0], {
      stroke: "#ffde00",
      strokeWidth: 2,
      originX: 'center',
      originY: 'center',
      top: 20
    });

    this.rampSpeedGroup = new fabric.Group([this.rampSpeedText, this.underLine], {
      originX: 'center',
      originY: 'center',
      selectable: true,
      lockRotation: true,
      lockScalingX: true,
      lockScalingY: true,
      lockMovementX: true,
      lockMovementY: true,
      hasControls: false,
      originX: 'center',
      originY: 'center',
      top : 100,
      left: this.left + 50
    });

    if(this.rampSpeedNumber <= 0) {
      this.rampSpeedGroup.setVisible(false);
    }
  }

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
  }

  this.manageBorderPrevious = function(color) {
    this.borderRight.stroke = color;
    if(this.previousStep) {
      this.previousStep.borderRight.stroke = color;
    }
  }

  this.render = function() {
    this.setLeft();
    this.addName();
    this.addBorderRight();
    this.getUniqueName();
    this.rampSpeed();
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

    this.canvas.add(this.stepRect);
    this.canvas.add(this.stepName);
    this.canvas.add(this.rampSpeedGroup);
    this.canvas.add(this.borderRight);
    this.addCircle();
  }

  this.selectStep = function(evt) {
    var me = this;
    if(ChaiBioTech.app.selectedStep) {
      var previouslySelected = ChaiBioTech.app.selectedStep;
      previouslySelected.darkFooterImage.visible = false;
      previouslySelected.whiteFooterImage.visible = false;
      // Change the border
      previouslySelected.manageBorderPrevious('#ff9f00');
      ChaiBioTech.app.selectedStep = this;
    } else {
      ChaiBioTech.app.selectedStep = this;
    }
    // Change the border
    this.manageBorder("black");
    this.darkFooterImage.visible = this.whiteFooterImage.visible = true;
    this.commonFooterImage.visible = false;
  }

  return this;
}
