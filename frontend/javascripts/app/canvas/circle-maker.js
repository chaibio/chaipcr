angular.module("canvasApp").factory('circleMaker', [
  function() {
    return function(left) {
      return new fabric.Circle({
        radius: 2,
        fill: 'white',
        left: left,
        selectable: false,
        name: "temperatureControllerLittleDude"
      });
    };
  }
]);
