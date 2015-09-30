window.ChaiBioTech.ngApp.factory('path', [
  'constants',
  function(constants) {
    return function(parent) {

      var x1 = parent.left + 60, y1 = parent.top,
      x2 = parent.next.left + 60, y2 = parent.next.top;

      var midPointX = (x1 + x2) / 2,
      midPointY = (y1 + y2) / 2;

      this.controlDistance = constants.controlDistance;

      var pathText = 'm '+ x1 +' ' + y1 +' Q '+ (x1 + this.controlDistance) +', '+ y1 +', ' + midPointX +', '+ midPointY +' Q '+ (x2 - this.controlDistance) +', '+ y2 +', '+ x2 +', '+ y2 +'';

      return new fabric.Path(pathText, {
        strokeWidth: 5,
        fill: '',
        stroke: '#ffd100',
        selectable: false,
        originX: "center",
        originY: "center",
        me: parent,
        name: "path",
        evented: false
      });
    };
  }
]);
