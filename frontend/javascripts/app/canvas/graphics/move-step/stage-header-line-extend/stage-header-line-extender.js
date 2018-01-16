angular.module('canvasApp').factory('stageHeaderLineExtender', [
  'Line',
  function(Line) {
    return function(width) {
      var properties = {
          originX: "left", originY: "top", x1: 0, y1: 24, x2: width, y2: 24, 
          stroke: 'white', strokeWidth: 2, selectable: false, left: 0, top: 24, width: width,
          visible: false
        };
      var cordinates = [0, 24, width, 24];

      return Line.create(cordinates, properties);
    };
  }
]);
