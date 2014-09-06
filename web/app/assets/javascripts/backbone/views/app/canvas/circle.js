ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.fabricCircle = function(model, parentStep) {
  this.model = model;
  this.parent = parentStep;
  this.canvas = parentStep.canvas;

  this.getLeft = function() {
    this.left = this.parent.left + 40;
  }

  this.getTop = function() {
    var temperature = this.model.get("step").temperature;
    this.top = 360 - (temperature * 3);
    // 360 is 300 + 60 that is height of step + padding from top, May be move this
    // to constants later;
  }

  this.getLines = function() {
    if(this.next) {
      this.circle.curve = new ChaiBioTech.app.Views.fabricPath(model, this, this.canvas);
    }
    // This is moved to here because we want to place circle over the line.
    // So first we add the line then circle is placed over it.
    this.canvas.add(this.circle);
  }

  this.render = function() {
    this.getLeft();
    this.getTop();
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
  }

  this.calculateControllingPoints = function(targetedCircle) {
    //targetedCircle.curve.path[1][1] =
  }

  this.canvas.on('object:moving', function(evt) {
    if(evt.target.name === "temperatureControllers") {
      var targetedCircle = evt.target, left = evt.target.left, top = evt.target.top;

      if(top < 60) {
        targetedCircle.top = 60;
      } else if(top > 360) {
        targetedCircle.top = 360;
      }

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

  return this;
}
