window.ChaiBioTech.ngApp.factory('outerMostCircle', [
  function() {
    return function() {
      return new fabric.Circle({
        radius: 36,
        fill: '#ffb400',
        originX: "center",
        originY: "center",
        selectable: false,
        visible: false,
        name: "temperatureControllerOuterMostCircle"
      });
    };
  }
]);
