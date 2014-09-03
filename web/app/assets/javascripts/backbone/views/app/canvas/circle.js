ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.fabricCircle = function(model, parentStep) {
  this.model = model;
  this.parent = parentStep;
  this.canvas = parentStep.canvas;
  var that = this;
  this.getLeft = function() {
    this.left = this.parent.left + 44;
  }

  this.render = function() {
    this.getLeft();
    this.circle = new fabric.Circle({
      radius: 16,
      stroke: 'white',
      left: this.left,
      lockMovementX: true,
      hasControls: false,
      hasBorders: false,
      top: 60,
      fill: '#ffb400',
      strokeWidth: 10,
      selectable: true
    });

    this.canvas.add(this.circle);
  }

  this.canvas.on('object:moving', function(evt) {
    console.log(that)
    evt.target.top = (evt.target.top < 60) ? 60 : evt.target.top;
    evt.target.top = (evt.target.top > 360) ? 360 : evt.target.top;
  });


  return this;
}
