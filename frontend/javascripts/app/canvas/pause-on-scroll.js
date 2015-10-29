window.ChaiBioTech.ngApp.factory('pauseStepCircleOnScroll', [
  function() {
    return function() {
      return new fabric.Circle({
        radius: 8,
        stroke: '#ffde00',
        originX: "center",
        originY: "center",
        fill: '#ffb400',
        strokeWidth: 3,
        selectable: false,
        name: "pauseDataCircleOnScroll"
      });
    };
  }
]);
