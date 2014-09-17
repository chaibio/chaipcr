ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.littleCircleGroup = function(littleCircles, parent) {

  return new fabric.Group(littleCircles, {
    originX:'center',
    originY: 'center',
    top: -1,
    visible: false
  });
}
