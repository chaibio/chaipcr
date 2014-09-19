ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.circleMaker = function(left) {

  return new fabric.Circle({
    radius: 3,
    fill: 'white',
    left: left,
    selectable: false,
    name: "temperatureControllerLittleDude"
  });
}
