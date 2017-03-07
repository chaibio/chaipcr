angular.module('canvasApp').service('stageBorderLeft', [
  'Line',
  function(Line) {
    return function(width) {
      var properties = {
          stroke: '#ff9f00',  left: 0, strokeWidth: 2, selectable: false
        };
      var cordinates = [0, 70, 0, 390];
      
      return Line.create(cordinates, properties);
    };
  }
]);
