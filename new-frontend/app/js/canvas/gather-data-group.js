window.ChaiBioTech.ngApp.factory('gatherDataGroup', [
  function() {
    return function(objs, parent) {

      var midPointY = null;

      if(parent.previous) {
        midPointY = (parent.top + parent.previous.top) / 2;
      }

      return new fabric.Group(objs, {
        left: parent.left,
        top: midPointY || 230,
        me: this,
        selectable: false,
        name: "gatherDataGroup",
        originX: "center",
        originY: "center",
        visible: false
      });
    };
  }
]);
