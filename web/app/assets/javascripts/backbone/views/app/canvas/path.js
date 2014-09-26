ChaiBioTech.app.Views = ChaiBioTech.app.Views || {};

ChaiBioTech.app.Views.fabricPath = function(model, parent, canvas) {
  this.model = model;
  this.parent = parent // parent is the circle
  this.canvas = canvas;

  var x1 = this.parent.circleGroup.left , y1 = this.parent.circleGroup.top,
  x2 = this.parent.next.circleGroup.left , y2 = this.parent.next.circleGroup.top;

  this.curve = new fabric.Path('m 0 10 Q 10, 20, 20, 10 Q 30, 0, 40, 10', {
    strokeWidth: 5,
    fill: '',
    stroke: '#ffd100',
    selectable: false,
    originX: "center",
    originY: "center"
  });

  // Starting point;
  this.curve.path[0][1] = x1;
  this.curve.path[0][2] = y1;

  var midPointX = (x1 + x2) / 2,
  midPointY = (y1 + y2) / 2;
  // Controlling point right now I take mid point
  this.curve.path[1][1] = (x1 + midPointX) / 2;
  this.curve.path[1][2] = ((y1 + midPointY) / 2) + 10;

  // Mid point
  this.curve.path[1][3] = midPointX;
  this.curve.path[1][4] = midPointY;
  // Controlling point for the next bent
  this.curve.path[2][1] = (midPointX + x2) / 2;
  this.curve.path[2][2] = ((midPointY + y2) / 2) - 15;
  // End Point
  this.curve.path[2][3] = x2;
  this.curve.path[2][4] = y2;
  
  this.canvas.add(this.curve);

  // We have nothing else to return , No member functions;
  return this.curve;
}
