ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.gatherDataGroupOnScroll = function(objs, parent) {

  return new fabric.Group(objs, {
    left: 20,
    top: -26,
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
