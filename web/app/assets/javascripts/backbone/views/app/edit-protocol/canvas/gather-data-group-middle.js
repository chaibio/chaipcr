ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.gatherDataGroupMiddle = function(objs, parent) {

  var midPointY = null;

  if(parent.previous) {
    midPointY = (parent.top) - 20;
  }

  return new fabric.Group(objs, {
    left: parent.left,
    top: midPointY || 230,
    width: 32,
    height: 32,
    me: this,
    selectable: false,
    name: "gatherDataGroupMiddle",
    originX: "center",
    originY: "center",
    visible: false
  });
}
