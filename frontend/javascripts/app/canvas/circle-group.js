window.ChaiBioTech.ngApp.factory('circleGroup', [
  'constants',
  function(constants) {
    return function(circles, parent) {
      return new fabric.Group(circles, {
        left: parent.left + (constants.stepWidth / 2),
        top: parent.top,
        me: parent,
        selectable: true,
        name: "controlCircleGroup",
        lockMovementX: true,
        hasControls: false,
        hasBorders: false,
        originX: "center",
        originY: "center",
      });
    };
  }
]);
