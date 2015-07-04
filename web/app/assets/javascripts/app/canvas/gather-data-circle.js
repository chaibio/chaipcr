window.ChaiBioTech.ngApp.factory('gatherDataCircle', [
  function() {
    return function() {
      return new fabric.Circle({
        radius: 16,
        stroke: '#ffde00',
        originX: "center",
        originY: "center",
        fill: '#ffb400',
        strokeWidth: 3,
        selectable: false,
        name: "gatherDataCircle"
      });
    };
  }
]);
