angular.module("canvasApp").factory('gatherDataCircle', [
  function() {
    return function() {
      return new fabric.Circle({
        radius: 13,
        stroke: '#ffde00',
        originX: "center",
        originY: "center",
        fill: '#ffb400',
        strokeWidth: 2,
        selectable: false,
        name: "gatherDataCircle"
      });
    };
  }
]);
