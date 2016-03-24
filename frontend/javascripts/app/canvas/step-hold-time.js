angular.module("canvasApp").factory('stepHoldTime', [
  function() {
    return function(model, parent) {

      this.model = model;
      this.parent = parent;
      this.canvas = parent.canvas;

      this.render = function() {

        this.holdTime = this.model.hold_time;

        this.text = new fabric.Text(this.formatHoldTime(), {
          fill: 'black',
          fontSize: 20,
          top : this.parent.top + 10,
          left: this.parent.left + 75,
          fontFamily: "dinot",
          //fontWeight: 'normal',
          selectable: false
        });
      };

      this.formatHoldTime = function() {

        var holdTimeHour = Math.floor(this.holdTime / 60);
        var holdTimeMinute = (this.holdTime % 60);

        holdTimeMinute = (holdTimeMinute < 10) ? "0" + holdTimeMinute : holdTimeMinute;

        return holdTimeHour + ":" + holdTimeMinute;
      };

      this.render();
      return this.text;
    };
  }
]);
