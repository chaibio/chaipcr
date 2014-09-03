ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.fabricCircle = function(model, parentStep) {
  this.model = model;
  this.parent = parentStep;
  this.canvas = parentStep.canvas;
  var that = this;
  this.getLeft = function() {
    this.left = this.parent.left + 44;
  }

  this.getTop = function() {
    var temperature = this.model.get("step").temperature;
    this.top = 360 - (temperature * 3);
    // 360 is 300 + 60 that is height of step + padding from top, May be move this
    // to constants later;
  }

  this.render = function() {
    this.getLeft();
    this.getTop();
    this.circle = new fabric.Circle({
      radius: 16,
      stroke: 'white',
      left: this.left,
      lockMovementX: true,
      hasControls: false,
      hasBorders: false,
      top: this.top,
      fill: '#ffb400',
      strokeWidth: 10,
      selectable: true
    });

    this.canvas.add(this.circle);
  }

  this.canvas.on('object:moving', function(evt) {
    evt.target.top = (evt.target.top < 60) ? 60 : evt.target.top;
    evt.target.top = (evt.target.top > 360) ? 360 : evt.target.top;
  });

  // May be have an array associated with stage that contains all the circles so that
  // its easy to add path [lines] to circles ... !
  return this;
}
