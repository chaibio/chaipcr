ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.gatherDataCircleOnScroll = function() {

  return new fabric.Circle({
    radius: 14,
    stroke: 'black',
    originX: "center",
    originY: "center",
    fill: 'black',
    strokeWidth: 3,
    selectable: false,
    name: "gatherDataCircleOnScroll"
  });
};
