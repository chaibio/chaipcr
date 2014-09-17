ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.circleGroup = function(circles, parent) {

  return new fabric.Group(circles, {
    left: parent.left,
    top: parent.top,
    me: parent,
    selectable: true,
    name: "controlCircleGroup",
    lockMovementX: true,
    hasControls: false,
    hasBorders: false,
  });
}
