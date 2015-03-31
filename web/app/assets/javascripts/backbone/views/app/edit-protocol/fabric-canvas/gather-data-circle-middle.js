ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.gatherDataCircleMiddle = function() {

  return new fabric.Circle({
    radius: 16,
    stroke: 'black',
    originX: "center",
    originY: "center",
    fill: 'black',
    strokeWidth: 3,
    selectable: false,
    name: "gatherDataCircleMiddle"
  });
}
