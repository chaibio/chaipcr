angular.module('canvasApp').factory('stageName', [
  'Text',
  function(Text) {
    return function() {
      properties = {
          fill: 'white', fontWeight: "400",  fontSize: 12,   fontFamily: "dinot",
          originX: "left", originY: "top", selectable: true
        };

        return Text.create("text comes here", properties);
    };
  }
]);
