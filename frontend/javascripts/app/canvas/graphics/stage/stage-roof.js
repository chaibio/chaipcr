angular.module('canvasApp').service('stageRoof', [
  'Line',
  function(Line) {
    return function(width) {
      var properties = {
          stroke: 'white', strokeWidth: 2, selectable: false, left: 0
        };
      var cordinates = [0, 24, width, 24];

      return Line.create(cordinates, properties);
    };
  }
]);
