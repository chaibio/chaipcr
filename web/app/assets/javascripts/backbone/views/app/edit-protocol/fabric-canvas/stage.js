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
  }

  this.addRoof = function() {
    this.roof = new fabric.Line([0, 0, (this.myWidth - 4), 0], {
        stroke: 'white',
        left: this.left + 2 || 32,
        top: 40,
        strokeWidth: 2,
        selectable: false
    });
  }

  this.borderLeft = function() {
    this.border = new fabric.Line([0, 0, 0, 342], {
      stroke: '#ff9f00',
      left: this.left - 2,
      top: 60,
      strokeWidth: 2,
      selectable: false
    });
  }
  //This is a special case only for the last stage
  this.borderRight = function() {
    this.borderRight = new fabric.Line([0, 0, 0, 342], {
      stroke: '#ff9f00',
      left: (this.left + this.myWidth) || 122,
      top: 60,
      strokeWidth: 2,
      selectable: false
    })
  }

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
  }

  this.writeMyName = function() {
    var stageName = (this.model.get("stage").name).toUpperCase();
    this.stageName = new fabric.IText(stageName, {
      fill: 'white',
      fontSize: 10,
      top : 28,
      left: this.left + 25 || 55,
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

  this.changeCycle = function() {
    this.cycleNo.text = this.updatedNoOfCycle;
    this.canvas.renderAll();
    this.cycleX.left = this.cycleNo.left + this.cycleNo.width + 3;
    this.cycles.left = this.cycleX.left + this.cycleX.width;
    this.canvas.renderAll();
  }

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
  }

  this.addSteps = function() {
    var steps = this.model.get("stage").steps;
    var tempStep = null;

    for(stepIndex in steps) {
      stepModel = new ChaiBioTech.Models.Step({"step": steps[stepIndex].step});
      stepView = new ChaiBioTech.app.Views.fabricStep(stepModel, this, stepIndex);

      if(tempStep) {
        tempStep.nextStep = stepView;
        stepView.previousStep = tempStep;
      }

      tempStep = stepView;
      this.childSteps.push(stepView);
      allSteps.push(stepView);
      stepView.ordealStatus = allSteps.length;
      stepView.render();
    }
    stepView.borderRight.visible = false;
  }

  this.findLastStep = function() {
    this.childSteps[0].circle.doThingsForLast();
  }

  this.render = function() {
      this.getLeft();
      this.addRoof();
      this.borderLeft();
      this.writeMyNo();
      this.writeMyName();
      this.writeNoOfCycles();
      this.stageRect = new fabric.Rect({
        left: this.left || 30,
        top: 16,
        fill: '#ffb400',
        width: this.myWidth,
        height: 384,
        selectable: false
      });
      this.canvas.add(this.stageRect);
      this.canvas.add(this.roof);
      this.canvas.add(this.border);
      this.canvas.add(this.stageNo);
      this.canvas.add(this.stageName);
      if(this.model.get("stage").stage_type === "cycling" && this.model.get("stage").steps.length > 1) {
        this.canvas.add(this.cycleNo);
        this.canvas.add(this.cycleX);
        this.canvas.add(this.cycles);
      }
      this.addSteps();
      this.canvas.renderAll();
  }

  this.manageBordersOnSelection = function(color) {
    this.border.stroke = color;
    if(this.nextStage) {
      this.nextStage.border.setStroke(color);
    } else {
      this.borderRight.setStroke(color);
    }
  }

  this.manageFooter = function(visible, color, length) {
    for(var i = 0; i< length; i++) {
        this.childSteps[i].commonFooterImage.visible = visible;
        this.childSteps[i].stepName.fill = color;
    }
  }

  this.selectStage =  function() {
    var me = this,
    length = me.childSteps.length;

    if(ChaiBioTech.app.selectedStage) {
      var previouslySelected = ChaiBioTech.app.selectedStage;
      // if the previous and current stages are same.
      //if(previouslySelected.stageNo.text != me.stageNo.text) {
        var previousLength = previouslySelected.childSteps.length;
        //Previus stage is changed back to original stage
        previouslySelected.roof.stroke = "white";
        previouslySelected.stageNo.fill = "white";
        previouslySelected.stageName.fill = "white";
        previouslySelected.cycleNo.fill = previouslySelected.cycleX.fill = previouslySelected.cycles.fill = "white";
        // Now we put the border back to normal
        previouslySelected.manageBordersOnSelection("#ff9f00");
        // the step which was selected is being cleared
        previouslySelected.manageFooter(false, "white", previousLength);
        ChaiBioTech.app.selectedStage = me;
    //  }

    } else {
      ChaiBioTech.app.selectedStage = me;
    }

    // We change the border
    me.manageBordersOnSelection("#cc6c00");
    // showing footer for the stage which is selected.
    me.manageFooter(true, "black", length);
    //Change current stage
    me.roof.stroke = "black";
    me.stageNo.fill = "black";
    me.stageName.fill = "black";
    me.cycleNo.fill = me.cycleX.fill = me.cycles.fill = "black";
  }

  return this;
}
