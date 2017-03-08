angular.module('canvasApp').factory('stageDotsBackground', [
  'Rectangle',
  function(Rectangle) {
    return function(width) {

      var properties = {
        width: 15, height: 14, fill: '#FFB300', left: 0, top: -2, selectable: false,
        originX: 'left', originY: 'top'
      };

      return Rectangle.create(properties);
    };
  }
]);
