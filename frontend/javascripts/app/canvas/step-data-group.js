angular.module("canvasApp").factory('stepDataGroup', [
  function() {
    return function(dataArray, parent) {
      return new fabric.Group(dataArray, {
        top: parent.top + 48,
        left: parent.left + 60,
        originX: "center",
        originY: "center",
        selectable: false,
        evented: false,
      });
    };
  }
]);
