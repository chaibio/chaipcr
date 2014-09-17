ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.outerCircle = function() {

  return new fabric.Circle({
    radius: 23,
    originX: "center",
    originY: "center",
    hasBorders: false,
    fill: '#ffb400',
    selectable: false,
    name: "temperatureControllerOuterCircle"
  });
}
