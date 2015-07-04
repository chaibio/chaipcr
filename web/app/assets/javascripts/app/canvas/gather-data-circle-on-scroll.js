window.ChaiBioTech.ngApp.factory('gatherDataCircleOnScroll', [
  function() {
    return function() {
      return new fabric.Circle({
        radius: 13,
        stroke: 'black',
        originX: "center",
        originY: "center",
        fill: 'black',
        strokeWidth: 2,
        selectable: false,
        name: "gatherDataCircleOnScroll"
      });
    };
  }
]);
