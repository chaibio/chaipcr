ChaiBioTech.app.Views = ChaiBioTech.app.Views || {};

ChaiBioTech.app.Views.fabricSelectionImage = function(url, parentStep, canvas) {

  this.parent = parentStep;
  this.canvas = parentStep.canvas;

  this.getImage = function(canvas, that) {
    fabric.Image.fromURL(url, function(img) {
     canvas.fire("image:loaded", that);
     return img;
    });
  }

  return this.getImage(canvas, this);


}
