ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.gatherDataCircleOnScroll = function() {

  return new fabric.Circle({
    radius: 13,
    stroke: 'black',
    originX: "center",
    originY: "center",
    fill: 'black',
    strokeWidth: 2,
    selectable: false,
    name: "gatherDataCircleOnScroll"
  });
};
