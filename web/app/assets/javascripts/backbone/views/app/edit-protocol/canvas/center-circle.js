ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.centerCircle = function() {

  return new fabric.Circle({
    radius: 13,
    stroke: 'white',
    originX: "center",
    originY: "center",
    fill: '#ffb400',
    strokeWidth: 10,
    selectable: false,
    name: "temperatureControllers"
  });
}
