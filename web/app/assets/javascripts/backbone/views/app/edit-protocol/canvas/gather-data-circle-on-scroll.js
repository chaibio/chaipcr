ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.gatherDataCircleOnScroll = function() {

  return new fabric.Circle({
    radius: 14,
    stroke: 'white',
    originX: "center",
    originY: "center",
    fill: 'white',
    strokeWidth: 3,
    selectable: false,
    name: "gatherDataCircleOnScroll"
  });
};
