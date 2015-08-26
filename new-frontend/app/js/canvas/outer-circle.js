window.ChaiBioTech.ngApp.factory('outerCircle', [
  function() {
    return function() {
      return new fabric.Circle({
        radius: 23,
        originX: "center",
        originY: "center",
        hasBorders: false,
        fill: '#ffb400',
        selectable: false,
        name: "temperatureControllerOuterCircle"
      });
    };
  }
]);
