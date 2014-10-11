ChaiBioTech.app.Views = ChaiBioTech.app.Views || {};

ChaiBioTech.app.Views.stepTemperature = function(model, parent) {

  this.model = model;
  this.parent = parent;
  this.canvas = parent.canvas;
  this.stepData = this.model.get("step");

  this.render = function() {
    var temp = parseFloat(this.stepData['temperature']);
    temp = (temp < 100) ? temp.toFixed(1) : temp;
    this.text = new fabric.Text(temp +"º", {
      fill: 'black',
      fontSize: 30,
      top : this.parent.top + 30,
      left: this.parent.left - 15,
      fontFamily: "Ostrich Sans",
      selectable: false,
      fontWeight: "800"
    });
    //this.canvas.add(this.text);
  }
  this.render();
  return this.text;
}
