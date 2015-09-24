window.ChaiBioTech.ngApp.factory('outerMostCircle', [
  function() {
    return function() {
      return new fabric.Rect({ // See this was a circle and now converted to a rectangle, Change the name later
        //radius: 36,
        width: 62,
        height: 40,
        fill: '#ffb400',
        originX: "center",
        originY: "center",
        selectable: false,
        visible: false,
        name: "temperatureControllerOuterMostCircle"
      });
    };
  }
]);
