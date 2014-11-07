ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.gatherDataGroupOnScroll = function(objs, parent) {

  return new fabric.Group(objs, {
    left: parent.left + 86,
    top: 120,
    width: 32,
    height: 32,
    me: this,
    selectable: false,
    name: "gatherDataGroupOnScroll",
    originX: "center",
    originY: "center",
    visible: false
  });
};
