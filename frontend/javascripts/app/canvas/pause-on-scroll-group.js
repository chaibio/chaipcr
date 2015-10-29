window.ChaiBioTech.ngApp.factory('pauseStepOnScrollGroup', [
  function() {
    return function(objs, parent) {
      return new fabric.Group(objs, {
        left: 20,
        top: -18,
        //width: 32,
        //height: 32,
        me: this,
        selectable: false,
        name: "pauseStepOnScrollGroup",
        originX: "center",
        originY: "center",
        visible: false
      });
    };
  }
]);
