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
    this.left = this.parent.left + 28;
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

  this.makeItBig = function(evt) {
    this.circle.setStroke("#ffb400");
    this.outerCircle.setStroke("black");
    this.outerCircle.strokeWidth = 7;
    this.stepDataGroup.setVisible(false);
    this.outerMostCircle.setVisible(true);
    this.littleCircleGroup.setVisible(true);
    // Calling the parent stage so that it looks for all the changes
    this.parent.parentStage.selectStage(this);
    //Calling the parent step class to add footer image to step
    this.parent.selectStep(this);
  }

  this.makeItSmall = function(evt) {
    this.circle.setStroke("white");
    this.outerCircle.stroke = null;
    this.littleCircleGroup.setVisible(false);
    this.stepDataGroup.setVisible(true);
    this.outerMostCircle.setVisible(false);
  }

  this.canvas.on('object:moving', function(evt) {
    if(evt.target.name === "controlCircleGroup") {
      var targetCircleGroup = evt.target,
      me = evt.target.me;

      // Move temperature display along with circle
      me.stepDataGroup.top = targetCircleGroup.top + 55;

      // Limit the movement of the circle
      var top = targetCircleGroup.top,
      left = targetCircleGroup.left;

      if(top < 60) {
        targetCircleGroup.setTop(60);
      } else if(top > 290) {
        targetCircleGroup.setTop(290);
      }

      // Change temperature display as it circle is moved
      var dynamicTemp = Math.abs((100 - ((targetCircleGroup.top - me.scrollTop) / me.scrollRatio)).toFixed(1));
      me.temperature.text = ""+dynamicTemp+"º";

      // Now positioning the ramp lines
      left = left - 6;
      top = top + 32;

      if(me.next) {
          me.curve.path[0][1] = left;
          me.curve.path[0][2] = top;
          // Calculating the mid point of the line at the right side of the circle
          // Remeber take the point which is static at the other side
          var leftOfLineRight = me.curve.path[1][3],
          topOfLineRight = me.curve.path[1][4];

          me.curve.path[1][1] = (left + leftOfLineRight) / 2;
          me.curve.path[1][2] = ((top + topOfLineRight) / 2) + 20;
      }

      if(me.previous) {
          previous = me.previous;
          previous.curve.path[1][3] = left;
          previous.curve.path[1][4] = top;
          // Calculating the mid point of the line at the left side of the cycle
          // Remeber take the point which is static at the other side
          var leftOfLineLeft = previous.curve.path[0][1],
          topOfLineLeft = previous.curve.path[0][2];

          previous.curve.path[1][1] = (left + leftOfLineLeft) / 2;
          previous.curve.path[1][2] = ((top + topOfLineLeft) / 2) + 20;
      }
      me.setCoords();
    }
  });

  this.canvas.on("mouse:down", function(evt) {
    if(evt.target && evt.target.name === "controlCircleGroup") {
        var targetedCircleGroup = evt.target,
        me = evt.target.me;
        me.makeItBig(evt);

        if(ChaiBioTech.app.selectedCircle) {
          var previousSelected = ChaiBioTech.app.selectedCircle;
          if(previousSelected.uniqueName != evt.target.me.uniqueName) {
            previousSelected.makeItSmall(evt);
            ChaiBioTech.app.selectedCircle = evt.target.me;
          }
        } else {
          ChaiBioTech.app.selectedCircle = evt.target.me;
        }
    }
  });

  return this;
}
