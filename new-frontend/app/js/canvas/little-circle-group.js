window.ChaiBioTech.ngApp.factory('littleCircleGroup', [
  function() {
    return function(littleCircles, parent) {
      return new fabric.Group(littleCircles, {
        originX:'center',
        originY: 'center',
        top: 0,
        visible: false,
        selectable: false
      });
    };
  }
]);
