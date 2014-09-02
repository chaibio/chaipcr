ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.fabricStage = function(model, stage, index) {
  this.model = model;
  this.canvas = stage;
  this.myWidth = this.model.get("stage").steps.length * 122;

  this.getLeft = function() {
    if(this.previousStage) {
      this.left = this.previousStage.StageRect.left + this.previousStage.StageRect.currentWidth;
    }
  }

  this.addRoof = function() {
    this.roof = new fabric.Line([0, 0, (this.myWidth - 4), 0], {
        stroke: 'white',
        left: this.left + 2 || 32,
        top: 40,
        strokeWidth: 2,
        selectable: false
    });
  }

  this.borderLeft = function() {
    this.border = new fabric.Line([0, 0, 0, 342], {
      stroke: '#ff9f00',
      left: this.left || 30,
      top: 60,
      strokeWidth: 2,
      selectable: false
    });
  }
  //This is a special case only for the last stage
  this.borderRight = function() {
    this.borderRight = new fabric.Line([0, 0, 0, 342], {
      stroke: '#ff9f00',
      left: (this.left + this.myWidth) || 122,
      top: 60,
      strokeWidth: 2,
      selectable: false
    })
  }

  this.render = function() {
      this.getLeft();
      this.addRoof();
      this.borderLeft();
      this.StageRect = new fabric.Rect({
        left: this.left || 30,
        top: 16,
        fill: '#ffb400',
        width: this.myWidth,
        height: 384,
        selectable: false
      });
      this.canvas.add(this.StageRect);
      this.canvas.add(this.roof);
      this.canvas.add(this.border);
  }

  return this;
}
