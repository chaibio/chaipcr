window.ChaiBioTech.ngApp.factory('stepHoldTime', [
  function() {
    return function(model, parent) {

      this.model = model;
      this.parent = parent;
      this.canvas = parent.canvas;

      this.render = function() {

        this.holdTime = this.model.hold_time;

        this.text = new fabric.Text(this.formatHoldTime(), {
          fill: 'black',
          fontSize: 30,
          top : this.parent.top + 30,
          left: this.parent.left + 40,
          fontFamily: "Ostrich Sans",
          fontWeight: 'normal',
          selectable: false
        });
      };

      this.formatHoldTime = function() {

        var holdTimeHour = Math.floor(this.holdTime / 60);
        var holdTimeMinute = (this.holdTime % 60);

        holdTimeMinute = (holdTimeMinute === 0) ? "00" : holdTimeMinute;
        return holdTimeHour + ":" + holdTimeMinute;
      };

      this.render();
      return this.text;
    };
  }
]);
