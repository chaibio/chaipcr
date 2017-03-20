angular.module('canvasApp').factory('stageRect', [
  'Rectangle',
  'constants',
  function(Rectangle, constants) {
    return function() {
      var properties = {
          left: 0,  top: 0, fill: '#FFB300',  width: constants.stepWidth,  height: 400,  selectable: false
        };
        return Rectangle.create(properties);
    };
  }
]);
