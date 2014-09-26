ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}
ChaiBioTech.app.selectedCircle = null;

ChaiBioTech.app.Views.fabricCircle = function(model, parentStep) {
  this.model = model;
  this.parent = parentStep;
  this.canvas = parentStep.canvas;
  this.scrollTop = 60;
  this.scrollLength = 290;
  this.scrollRatio = (this.scrollLength - this.scrollTop) / 100;

  this.getLeft = function() {
    this.left = this.parent.left;
  }

  this.getTop = function() {
    var temperature = this.model.get("step").temperature;
    this.top = this.scrollLength - (temperature * this.scrollRatio);
    // 300 is 240 + 60 that is height of step + padding from top, May be move this
    // to constants later;
  }

  this.getLines = function() {
    // This is moved to here because we want to place circle over the line.
    // So first we add the line then circle is placed over it.
    if(this.next) {
      this.curve = new ChaiBioTech.app.Views.fabricPath(model, this, this.canvas);
    }
    // Here too this order is important
    this.canvas.add(this.stepDataGroup);
    this.canvas.add(this.circleGroup);
  }

  this.getUniqueId = function() {
    var name = this.parent.stepName.text;
    name = name + this.parent.parentStage.stageNo.text + "circle";
    this.uniqueName = name;
  }

  this.render = function() {
    this.getLeft();
    this.getTop();
    this.getUniqueId();

    // place the circle Group Note this order is important
    this.circleGroup = new ChaiBioTech.app.Views.circleGroup(
      [
        this.outerMostCircle = new ChaiBioTech.app.Views.outerMostCircle(),
        this.outerCircle = new ChaiBioTech.app.Views.outerCircle(),
        this.circle = new ChaiBioTech.app.Views.centerCircle(),
        this.littleCircleGroup = new ChaiBioTech.app.Views.littleCircleGroup(
          [
            this.littleCircle1 = new ChaiBioTech.app.Views.circleMaker(-10),
            this.littleCircle2 = new ChaiBioTech.app.Views.circleMaker(-2),
            this.littleCircle3 = new ChaiBioTech.app.Views.circleMaker(6)
          ]
        )
      ], this);

    // Place temperature and hold time data
    this.stepDataGroup = new ChaiBioTech.app.Views.stepDataGroup([
        this.temperature = new ChaiBioTech.app.Views.stepTemperature(this.model, this),
        this.holdTime = new ChaiBioTech.app.Views.holdTime(this.model, this)
      ], this);
  }

  this.makeItBig = function() {
    this.circle.stroke = "#ffb400";
    this.outerCircle.stroke = "black";
    this.outerCircle.strokeWidth = 7;
    this.stepDataGroup.visible = false;
    this.outerMostCircle.visible = true;
    this.littleCircleGroup.visible = true;
    // Calling the parent stage so that it looks for all the changes
    this.parent.parentStage.selectStage(this);
    //Calling the parent step class to add footer image to step
    this.parent.selectStep(this);
  }

  this.makeItSmall = function() {
    this.circle.stroke = "white";
    this.outerCircle.stroke = null;
    this.littleCircleGroup.visible = false;
    this.stepDataGroup.visible = true;
    this.outerMostCircle.visible = false;
  }

  this.manageDrag = function(targetCircleGroup) {
    // Limit the movement of the circle
    var top = targetCircleGroup.top,
    left = targetCircleGroup.left;

    if(top < 60) {
      targetCircleGroup.setTop(60);
    } else if(top > 290) {
      targetCircleGroup.setTop(290);
    } else {
      // Move temperature display along with circle
      this.stepDataGroup.setTop(top + 55);
      // Now positioning the ramp lines
      left = left;
      top = top;

      if(this.next) {
          this.curve.path[0][1] = left;
          this.curve.path[0][2] = top;
          // Calculating the mid point of the line at the right side of the circle
          // Remeber take the point which is static at the other side
          var endPointX = this.curve.path[2][3],
          endPointY = this.curve.path[2][4];


          var midPointX = (left + endPointX) / 2,
          midPointY = (top + endPointY) / 2;

          this.curve.path[1][1] = (left + midPointX) / 2;
          this.curve.path[1][2] = ((top + midPointY) / 2) + 10;

          // Mid point
          this.curve.path[1][3] = midPointX;
          this.curve.path[1][4] = midPointY;

          // Controlling point for the next bent
          this.curve.path[2][1] = (midPointX + endPointX) / 2;
          this.curve.path[2][2] = ((midPointY + endPointY) / 2) - 15;
      }

      if(this.previous) {
          previous = this.previous;
          previous.curve.path[2][3] = left;
          previous.curve.path[2][4] = top;
          // Calculating the mid point of the line at the left side of the cycle
          // Remeber take the point which is static at the other side
          var endPointX = previous.curve.path[0][1],
          endPointY = previous.curve.path[0][2];

          var midPointX = (left + endPointX) / 2,
          midPointY = (top + endPointY) / 2;

          previous.curve.path[2][1] = (left + midPointX) / 2;
          previous.curve.path[2][2] = ((top + midPointY) / 2 ) - 15;

          // Mid point
          previous.curve.path[1][3] = midPointX;
          previous.curve.path[1][4] = midPointY;

          previous.curve.path[1][1] = (midPointX + endPointX) / 2;
          previous.curve.path[1][2] = ((midPointY + endPointY) / 2) + 10;

      }

      // Change temperature display as its circle is moved
      var dynamicTemp = Math.abs((100 - ((targetCircleGroup.top - this.scrollTop) / this.scrollRatio)).toFixed(1));
      this.temperature.text = ""+dynamicTemp+"º";
    }
  }

  this.manageClick = function() {
    this.makeItBig();
    if(ChaiBioTech.app.selectedCircle) {
      var previousSelected = ChaiBioTech.app.selectedCircle;
      if(previousSelected.uniqueName != this.uniqueName) {
        previousSelected.makeItSmall();
        ChaiBioTech.app.selectedCircle = this;
      }
    } else {
      ChaiBioTech.app.selectedCircle = this;
    }
  }

  return this;
}
