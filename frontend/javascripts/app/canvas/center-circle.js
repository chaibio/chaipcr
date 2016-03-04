angular.module("canvasApp").factory('centerCircle', [
  function() {
    return function() {
      return new fabric.Circle({
        radius: 11,
        stroke: 'white',
        originX: "center",
        originY: "center",
        fill: '#ffb400',
        strokeWidth: 8,
        selectable: false,
        name: "temperatureControllers"
      });
    };
  }
]);
