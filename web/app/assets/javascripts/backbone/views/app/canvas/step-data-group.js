ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.stepDataGroup = function(dataArray, parent) {

  return new fabric.Group(dataArray, {
    top: parent.top + 55,
    left: parent.left + 60,
    originX: "center",
    originY: "center",
    selectable: false
  });
}
