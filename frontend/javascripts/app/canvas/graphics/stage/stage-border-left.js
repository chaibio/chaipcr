angular.module('canvasApp').factory('stageBorderLeft', [
  'Line',
  function(Line) {
    return function(stage) {
      var properties = {
          stroke: '#ff9f00',  left: stage.left, strokeWidth: 2, selectable: false
        };
      var cordinates = [0, 70, 0, 390];

      return Line.create(cordinates, properties);
    };
  }
]);
