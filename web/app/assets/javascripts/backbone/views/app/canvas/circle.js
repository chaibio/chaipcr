ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.fabricCircle = function(model, parentStep) {
  this.model = model;
  this.parent = parentStep;
  this.canvas = parentStep.canvas;
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
      var x1 = this.circle.left + 13, y1 = this.circle.top + 13,
      x2 = this.next.circle.left + 13, y2 = this.next.circle.top + 13,
      curvatureY = this.parent.left + 120,
      pathString = 'M '+x1+' '+y1+' Q '+70 +', '+ curvatureY+', '+x2 +', '+y2;
      console.log(x1,y1,x2,y2);
      this.rightLine = new fabric.Line([x1, y1 , x2, y2], {
        left: x1,
        top: (y1 > y2) ? y2 : y1,
        strokeWidth: 5,
        fill: '#ffd100',
        stroke: '#ffd100'
      });
     this.canvas.add(this.rightLine);
    //this.canvas.add(this.point);
    }
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
    this.canvas.add(this.circle);
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
