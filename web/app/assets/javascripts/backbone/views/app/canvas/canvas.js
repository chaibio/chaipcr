ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.fabricCanvas = function(model) {
  this.model = model;

  this.canvas = new fabric.Canvas('canvas', {
    backgroundColor: '#ffb400',
    selectionColor: 'blue'
  });
  this.canvas.setHeight(420);
  this.canvas.setWidth(1024);

  // This goes to different part for creating step stage ... !!!
  var rect = new fabric.Rect({
    left: 100,
    top: 100,
    fill: 'red',
    width: 20,
    height: 20,
    angle: 45
  });

this.canvas.add(rect);
canvas.renderAll();
}
