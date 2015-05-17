ChaiBioTech.app.Views = ChaiBioTech.app.Views || {};
ChaiBioTech.app.selectedStage = null;

ChaiBioTech.app.Views.fabricStage = function(model, stage, allSteps, index, fabricStage) {

  this.model = model;
  this.index = index;
  this.canvas = stage;
  this.myWidth = this.model.get("stage").steps.length * 120;
  this.parent = fabricStage;
  this.childSteps = [];
  this.previousStage = null;
  this.nextStage = null;
  this.noOfCycles = null;

  this.getLeft = function() {

    if(this.previousStage) {
      this.left = this.previousStage.stageRect.left + this.previousStage.stageRect.currentWidth + 2;
    } else {
      this.left = 32;
    }

    return this;
  };

  this.addRoof = function() {

    this.roof = new fabric.Line([0, 0, (this.myWidth - 4), 0], {
        stroke: 'white',
        left: this.left + 2 || 32,
        top: 40,
        strokeWidth: 2,
        selectable: false
    });

    return this;
  };

  this.borderLeft = function() {

    this.border = new fabric.Line([0, 0, 0, 342], {
      stroke: '#ff9f00',
      left: this.left - 2,
      top: 60,
      strokeWidth: 2,
      selectable: false
    });

    return this;
  };
  //This is a special case only for the last stage
  this.borderRight = function() {

    this.borderRight = new fabric.Line([0, 0, 0, 342], {
      stroke: '#ff9f00',
      left: (this.left + this.myWidth) || 122,
      top: 60,
      strokeWidth: 2,
      selectable: false
    });

    return this;
  };

  this.writeMyNo= function() {

    var temp = parseInt(this.index) + 1;

    if(temp < 10) {
      temp = "0" + temp;
    }

    this.stageNo = new fabric.Text(temp, {
      fill: 'white',
      fontSize: 32,
      top : 5,
      left: this.left + 2 || 32,
      fontFamily: "Ostrich Sans",
      selectable: false
    });

    return this;
  };

  this.writeMyName = function() {

    var stageName = (this.model.get("stage").name).toUpperCase();

    this.stageName = new fabric.Text(stageName, {
      fill: 'white',
      fontSize: 9,
      top : 28,
      left: this.left + 25 || 55,
      fontFamily: "Open Sans",
      selectable: false,
      editable: false,
      lockRotation: true,
      lockScalingX: true,
      lockScalingY: true,
      lockMovementX: true,
      lockMovementY: true,
      hasControls: false
    });

    return this;
  };

  this.changeCycle = function() {

    this.cycleNo.text = this.updatedNoOfCycle;
    this.cycleX.left = this.cycleNo.left + this.cycleNo.width + 3;
    this.cycles.left = this.cycleX.left + this.cycleX.width;
    this.canvas.renderAll();
  };

  this.writeNoOfCycles = function() {

    this.noOfCycles = this.noOfCycles || this.model.get("stage").num_cycles;

    this.cycleNo = new fabric.Text(String(this.noOfCycles), {
      fill: 'white',
      fontSize: 32,
      top : 5,
      fontWeight: "bold",
      left: this.left + 120 || 120,
      fontFamily: "Ostrich Sans",
      selectable: false,
      hasControls: false
    });

    this.cycleX = new fabric.Text("x", {
      fill: 'white',
      fontSize: 22,
      top : 15,
      left: this.left + this.cycleNo.width + 120 || 140 + this.cycleNo.width + 120,
      fontFamily: "Ostrich Sans",
      selectable: false,
      hasControls: false
    });

    this.cycles = new fabric.Text("CYCLES", {
      fill: 'white',
      fontSize: 10,
      top : 28,
      left: this.left + this.cycleX.width + this.cycleNo.width + 125 || 140 + this.cycleX.width + this.cycleNo.width + 125,
      fontFamily: "Open Sans",
      selectable: false,
      hasControls: false
    });

    return this;
  };

  this.addSteps = function() {

    var steps = this.model.get("stage").steps;
    var tempStep = null;
    this.childSteps = new Array();

    for(stepIndex in steps) {
      stepModel = new ChaiBioTech.Models.Step({"step": steps[stepIndex].step});
      stepView = new ChaiBioTech.app.Views.fabricStep(stepModel, this, stepIndex);

      if(tempStep) {
        tempStep.nextStep = stepView;
        stepView.previousStep = tempStep;
      }

      if(ChaiBioTech.app.newStepId && steps[stepIndex].step.id === ChaiBioTech.app.newStepId) {
        ChaiBioTech.app.newlyCreatedStep = stepView;
        ChaiBioTech.app.newStepId = null;
      }

      tempStep = stepView;
      this.childSteps.push(stepView);
      allSteps.push(stepView);
      stepView.ordealStatus = allSteps.length;
      stepView.render();
    }
    stepView.borderRight.setVisible(false);
  }

  this.findLastStep = function() {

    this.childSteps[this.childSteps.length -1].circle.doThingsForLast();
  };

  this.render = function() {

      this.getLeft().addRoof().borderLeft().writeMyNo().writeMyName().writeNoOfCycles();

      this.stageRect = new fabric.Rect({
        left: this.left || 30,
        top: 16,
        fill: '#ffb400',
        width: this.myWidth,
        height: 384,
        selectable: false
      });

      this.canvas.add(this.stageRect, this.roof, this.border, this.stageNo, this.stageName);

      if(this.model.get("stage").stage_type === "cycling" && this.model.get("stage").steps.length > 1) {
        this.canvas.add(this.cycleNo, this.cycleX, this.cycles);
      }

      this.addSteps();
      this.canvas.renderAll();
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

    if(ChaiBioTech.app.selectedStage) {
      var previouslySelected = ChaiBioTech.app.selectedStage;
      var previousLength = previouslySelected.childSteps.length;

      previouslySelected.changeFillsAndStrokes("white");
      previouslySelected.manageBordersOnSelection("#ff9f00");
      previouslySelected.manageFooter(false, "white", previousLength);
      previouslySelected.moveImg.setVisible(false);
    }

    ChaiBioTech.app.selectedStage = this;
    this.changeFillsAndStrokes("black");
    this.manageBordersOnSelection("#cc6c00");
    this.manageFooter(true, "black", length);
    this.moveImg.setVisible(true);
  };

  return this;
};
