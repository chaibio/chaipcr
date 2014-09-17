ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.outerMostCircle = function() {

  return new fabric.Circle({
    radius: 36,
    fill: '#ffb400',
    originX: "center",
    originY: "center",
    selectable: false,
    visible: false,
    name: "temperatureControllerOuterMostCircle"
  });

}
