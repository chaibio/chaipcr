angular.module("canvasApp").factory('outerCircle', [
  function() {
    return function() {
      return new fabric.Circle({
        radius: 18,
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
