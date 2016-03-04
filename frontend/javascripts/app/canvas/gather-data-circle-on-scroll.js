angular.module("canvasApp").factory('gatherDataCircleOnScroll', [
  function() {
    return function() {
      return new fabric.Circle({
        radius: 8,
        stroke: 'black',
        originX: "center",
        originY: "center",
        fill: 'black',
        //strokeWidth: 2,
        selectable: false,
        name: "gatherDataCircleOnScroll"
      });
    };
  }
]);
