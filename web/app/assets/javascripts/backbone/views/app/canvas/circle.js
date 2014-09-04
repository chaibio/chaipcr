ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.fabricCircle = function(model, parentStep) {
  this.model = model;
  this.parent = parentStep;
  this.canvas = parentStep.canvas;
  this.spot = 16
  // This is original radius of the circle , never mind its 13 in code.
  // there comes some stroke;
  var that = this;
  this.getLeft = function() {
    this.left = this.parent.left + 40;
  }

  this.getTop = function() {
    var temperature = this.model.get("step").temperature;
    this.top = 360 - (temperature * 3);
    // 360 is 300 + 60 that is height of step + padding from top, May be move this
    // to constants later;
  }

  this.getLines = function(circleIndex) {
    if(this.next) {
      var x1 = this.circle.left - this.spot, y1 = this.circle.top + this.spot,
      x2 = this.next.circle.left - this.spot, y2 = this.next.circle.top + this.spot;

    /*  this.rightLine = new fabric.Line([x1, y1, x2, y2], {
        left: x1,
        top: (y1 > y2) ? y2 : y1,
        strokeWidth: 5,
        fill: '#ffd100',
        stroke: '#ffd100',
        selectable: false
      }); */

      this.path = new fabric.Path('m 65 0 Q 100, 100, 200, 0', {
        strokeWidth: 5,
        fill: '',
        stroke: '#ffd100',
        selectable: false
      });

      // Starting point;
      this.path.path[0][1] = x1;
      this.path.path[0][2] = y1;

      // Controlling point right now I take mid point
      this.path.path[1][1] = (x1 + x2) / 2;
      this.path.path[1][2] = ((y1 + y2) / 2) + 20;

      // End Point
      this.path.path[1][3] = x2;
      this.path.path[1][4] = y2;

     //this.canvas.add(this.rightLine);
     this.canvas.add(this.path);
     console.log("look", this.path.getBoundingRect());
    }
    this.canvas.add(this.circle);
    // This is moved to here because we want to place circle over the line.
    // So first we add the line then circle is placed over it.
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
      name: "temperatureControllers"
    });

  }

  this.canvas.on('object:moving', function(evt) {
    if(evt.target.name === "temperatureControllers") {
      evt.target.top = (evt.target.top < 60) ? 60 : evt.target.top;
      evt.target.top = (evt.target.top > 360) ? 360 : evt.target.top;
    }
  });

  // May be have an array associated with stage that contains all the circles so that
  // its easy to add path [lines] to circles ... !
  return this;
}
