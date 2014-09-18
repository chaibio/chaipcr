ChaiBioTech.app.Views = ChaiBioTech.app.Views || {};
ChaiBioTech.app.selectedStage = null;

ChaiBioTech.app.Views.fabricStage = function(model, stage, allSteps, index) {
  this.model = model;
  this.index = index;
  this.canvas = stage;
  this.myWidth = this.model.get("stage").steps.length * 120;
  this.childSteps = [];

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
    this.stageName = new fabric.Text(stageName, {
      fill: 'white',
      fontSize: 10,
      top : 28,
      left: this.left + 25 || 55,
      fontFamily: "Open Sans",
      selectable: false
    })
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
      stepView.render();
    }
    stepView.borderRight.visible = false;
  }

  this.render = function() {
      this.getLeft();
      this.addRoof();
      this.borderLeft();
      this.writeMyNo();
      this.writeMyName();
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
      this.addSteps();
      this.canvas.renderAll();
  }

  this.manageBordersOnSelection = function(color) {
    this.border.setStroke(color);
    if(this.nextStage) {
      this.nextStage.border.setStroke(color);
    } else {
      this.borderRight.setStroke(color);
    }
  }

  this.manageFooter = function(visible, color, length) {
    for(var i = 0; i< length; i++) {
        this.childSteps[i].commonFooterImage.setVisible(visible);
        this.childSteps[i].stepName.setFill(color);
    }
  }

  this.selectStage =  function(evt) {
    var me = (evt.target) ? evt.target.me.parentStage : this,
    length = me.childSteps.length;

    if(ChaiBioTech.app.selectedStage) {
      var previouslySelected = ChaiBioTech.app.selectedStage;
      // Fabric sends more than one event so we filter,
      // if the previous and current stages are same.
      if(previouslySelected.stageNo.text != me.stageNo.text) {
        var previousLength = previouslySelected.childSteps.length;
        //Previus stage is changed back to original stage
        previouslySelected.roof.setStroke("white");
        previouslySelected.stageNo.setFill("white");
        previouslySelected.stageName.setFill("white");
        // Now we put the border back to normal
        previouslySelected.manageBordersOnSelection("#ff9f00");
        // the step which was selected is being cleared
        previouslySelected.manageFooter(false, "white", previousLength);
        ChaiBioTech.app.selectedStage = me;
      }

    } else {
      ChaiBioTech.app.selectedStage = me;
    }

    // We change the border
    me.manageBordersOnSelection("#cc6c00");
    // showing footer for the stage which is selected.
    me.manageFooter(true, "black", length);
    //Change current stage
    me.roof.setStroke("black");
    me.stageNo.setFill("black");
    me.stageName.setFill("black");
  }

  return this;
}
