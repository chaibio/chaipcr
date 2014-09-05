ChaiBioTech.app.Views = ChaiBioTech.app.Views || {};

ChaiBioTech.app.Views.fabricPath = function(model, parent, canvas) {
  this.model = model;
  this.parent = parent // parent is the circle
  // This is original radius of the circle , never mind its 13 in code.
  // there comes some stroke;
  this.spot = 16;
  this.canvas = canvas;

  var x1 = this.parent.circle.left - this.spot, y1 = this.parent.circle.top + this.spot,
  x2 = this.parent.next.circle.left - this.spot, y2 = this.parent.next.circle.top + this.spot;

  this.curve = new fabric.Path('m 65 0 Q 100, 100, 200, 0', {
    strokeWidth: 5,
    fill: '',
    stroke: '#ffd100',
    selectable: false
  });

  // Starting point;
  this.curve.path[0][1] = x1;
  this.curve.path[0][2] = y1;

  // Controlling point right now I take mid point
  this.curve.path[1][1] = (x1 + x2) / 2;
  this.curve.path[1][2] = ((y1 + y2) / 2) + 20;

  // End Point
  this.curve.path[1][3] = x2;
  this.curve.path[1][4] = y2;

  this.canvas.add(this.curve);

  // We have nothing else to return , No member functions;
  return this.curve;
}
