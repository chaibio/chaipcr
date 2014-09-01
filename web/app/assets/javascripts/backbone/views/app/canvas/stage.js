ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.fabricStage = function(model, stage, index) {
  this.model = model;
  this.canvas = stage;
  this.myWidth = this.model.get("stage").steps.length * 122;

  this.getCoOrdinates = function() {
    if(this.previousStage) {
      console.log("On track")
    }
  }

  this.getLeft = function() {
    if(this.previousStage) {
      console.log(this.previousStage.rect1)
      this.left = this.previousStage.rect1.left + this.previousStage.rect1.currentWidth;
    }
  }

  this.render = function() {
      this.getLeft();
      this.rect1 = new fabric.Rect({
        left: this.left || 30,
        top: 16,
        fill: 'red',
        width: this.myWidth,
        height: 384,
        selectable: false
      });
      this.canvas.add(this.rect1);
  }

  return this;
}
