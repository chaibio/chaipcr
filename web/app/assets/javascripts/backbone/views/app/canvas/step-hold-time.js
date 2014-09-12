ChaiBioTech.app.Views = ChaiBioTech.app.Views || {};

ChaiBioTech.app.Views.holdTime = function(model, parent) {

  this.model = model;
  this.parent = parent;
  this.canvas = parent.canvas;

  this.render = function() {
    this.text = new fabric.Text("30", {
      fill: 'black',
      fontSize: 30,
      top : this.parent.top + 30,
      left: this.parent.left + 30,
      fontFamily: "Ostrich Sans",
      selectable: false
    });
    //this.canvas.add(this.text);
  }
  this.render();
  return this;
}
