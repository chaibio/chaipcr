angular.module('canvasApp').factory('stageCaption', [
  'Text',
  function(Text) {
    return function() {
      var properties = {
          fill: 'white', fontWeight: "400",  fontSize: 12,   fontFamily: "dinot-bold",
          originX: "left", originY: "top", selectable: true, left: 0
        };

        return Text.create("", properties);
    };
  }
]);
