ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.gatherDataGroup = function(objs, parent) {

  var midPointY = null;
  if(parent.next) {
    midPointY = (parent.top + parent.next.top) / 2;
  }
  return new fabric.Group(objs, {
    left: parent.left + 120,
    top: midPointY || 230,
    width: 32,
    height: 32,
    me: this,
    selectable: false,
    name: "gatherDataGroup",
    originX: "center",
    originY: "center",
  });

}
