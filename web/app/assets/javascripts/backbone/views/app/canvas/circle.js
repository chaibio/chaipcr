ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}
ChaiBioTech.app.selectedCircle = null;

ChaiBioTech.app.Views.fabricCircle = function(model, parentStep) {
  this.model = model;
  this.parent = parentStep;
  this.canvas = parentStep.canvas;

  this.getLeft = function() {
    this.left = this.parent.left + 40;
  }

  this.getTop = function() {
    var temperature = this.model.get("step").temperature;
    this.top = 300 - (temperature * 2.4);
    // 300 is 240 + 60 that is height of step + padding from top, May be move this
    // to constants later;
  }

  this.getLines = function() {
    if(this.next) {
      this.circle.curve = new ChaiBioTech.app.Views.fabricPath(model, this, this.canvas);
    }
    // This is moved to here because we want to place circle over the line.
    // So first we add the line then circle is placed over it.
    this.canvas.add(this.outerMostCircle);
    this.canvas.add(this.outerCircle);
    this.canvas.add(this.circle);
    this.canvas.add(this.stepDataGroup);
  }

  this.getUniqueId = function() {
    var name = this.parent.stepName.text;
    name = name + this.parent.parentStage.stageNo.text + "circle";
    this.uniqueName = name;
    //console.log("my name", this.name);
  }

  this.render = function() {
    this.getLeft();
    this.getTop();
    this.getUniqueId();
    this.circle = new fabric.Circle({
      radius: 13,
      stroke: 'white',
      left: this.left,
      lockMovementX: true,
      hasControls: false,
      hasBorders: false,
      top: this.top,
      fill: '#ffb400',
      strokeWidth: 10,
      selectable: true,
      name: "temperatureControllers",
      parent: this // We may need it when it fires some event
    });
    this.getOuterCircle();
    this.getOuterMostCircle();
    this.placeStepData();
  }

  this.calculateControllingPoints = function(targetedCircle) {
    //targetedCircle.curve.path[1][1] =
  }

  this.placeStepData = function() {
    this.temperature = new ChaiBioTech.app.Views.stepTemperature(this.model, this);
    this.holdTime = new ChaiBioTech.app.Views.holdTime(this.model, this);

    this.stepDataGroup = new fabric.Group([this.temperature.text, this.holdTime.text], {
      top: this.top + 30,
      left: this.left -15,
      selectable: false
    });
    //console.log(this.temperature);
  }

  this.getOuterCircle = function() {
    this.outerCircle = new fabric.Circle({
      radius: 25,
      left: this.left - 7,
      lockMovementX: true,
      hasControls: false,
      hasBorders: false,
      top: this.top - 7,
      fill: '#ffb400',
      selectable: false,
      name: "temperatureControllerOuterCircle",
      parent: this // We may need it when it fires some event
    })
  }

  this.getOuterMostCircle = function() {
    this.outerMostCircle = new fabric.Circle({
      radius: 35,
      left: this.left - 16,
      lockMovementX: true,
      hasControls: false,
      hasBorders: false,
      top: this.top - 16,
      fill: '#ffb400',
      selectable: false,
      visible: false,
      name: "temperatureControllerOuterMostCircle",
      parent: this // We may need it when it fires some event
    });
  }

  this.makeItBig = function(evt) {
    this.circle.stroke = "#ffb400";
    this.outerCircle.stroke = "black";
    this.outerCircle.strokeWidth = 7;
    this.stepDataGroup.visible = false;
    this.outerMostCircle.visible = true;
    // Calling the parent stage so that it looks for all the changes
    this.parent.parentStage.selectStage(this);
    //Calling the parent step class to add footer image to step
    this.parent.selectStep(this)
  }

  this.makeItSmall = function(evt) {
    this.circle.stroke = "white";
    this.outerCircle.stroke = null;
    this.stepDataGroup.visible = true;
    this.outerMostCircle.visible = false;
  }

  this.canvas.on('object:moving', function(evt) {
    if(evt.target.name === "temperatureControllers") {
      var targetedCircle = evt.target, left = evt.target.left, top = evt.target.top,
      outerCircle = targetedCircle.parent.outerCircle,
      outerMostCircle = targetedCircle.parent.outerMostCircle,
      dataGroup = targetedCircle.parent.stepDataGroup,
      dataTemperature = targetedCircle.parent.temperature,
      dynamicTemp;
      //console.log(dataTemperature.text.text);
      if(top < 60) {
        targetedCircle.top = 60;
      } else if(top > 300) {
        targetedCircle.top = 300;
      }
      outerCircle.top = targetedCircle.top - 7;
      outerMostCircle.top = targetedCircle.top - 16;
      dataGroup.top = targetedCircle.top + 30;
      dynamicTemp = (100 - ((targetedCircle.top - 60) / 2.4)).toFixed(1);
      dataTemperature.text.text = ""+dynamicTemp+"º";
      // 2.4 = (300 - 60)/ 100
      // 300 is the scroll length
      // 60 is the top of the step
      // Later move these values to constants
      //targetedCircle.parent.canvas.renderAll();

      left = left - 16;
      top = top + 16;

      if(targetedCircle.parent.next) {
          targetedCircle.curve.path[0][1] = left;
          targetedCircle.curve.path[0][2] = top;

          // Calculating the mid point of the line at the right side of the circle
          // Remeber take the point which is static at the other side
          var leftOfLineRight = targetedCircle.curve.path[1][3],
          topOfLineRight = targetedCircle.curve.path[1][4];

          targetedCircle.curve.path[1][1] = (left + leftOfLineRight) / 2;
          targetedCircle.curve.path[1][2] = ((top + topOfLineRight) / 2) + 20;
      }

      if(targetedCircle.parent.previous) {
          previous = targetedCircle.parent.previous;
          previous.circle.curve.path[1][3] = left;
          previous.circle.curve.path[1][4] = top;

          // Calculating the mid point of the line at the left side of the cycle
          // Remeber take the point which is static at the other side
          var leftOfLineLeft = previous.circle.curve.path[0][1],
          topOfLineLeft = previous.circle.curve.path[0][2];

          previous.circle.curve.path[1][1] = (left + leftOfLineLeft) / 2;
          previous.circle.curve.path[1][2] = ((top + topOfLineLeft) / 2) + 20;
      }
    }
  });

  this.canvas.on("mouse:down", function(evt) {
    if(evt.target && evt.target.name === "temperatureControllers") {
        var targetedCircle = evt.target,
        thisCircle = evt.target.parent;
        //thisCircle.mekeItBig(evt);
        evt.target.parent.makeItBig(evt);

        if(ChaiBioTech.app.selectedCircle) {
          var previousSelected = ChaiBioTech.app.selectedCircle;
          if(previousSelected.uniqueName != evt.target.parent.uniqueName) {
            previousSelected.makeItSmall(evt);
            ChaiBioTech.app.selectedCircle = evt.target.parent;
          }
        } else {
          ChaiBioTech.app.selectedCircle = evt.target.parent;
        }
    }
  });

  return this;
}
