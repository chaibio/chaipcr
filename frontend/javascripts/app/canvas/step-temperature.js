angular.module("canvasApp").factory('stepTemperature', [
  'editMode',
  function(editMode) {
    return function(model, parent) {

      this.model = model;
      this.parent = parent;
      this.canvas = parent.canvas;
      this.stepData = this.model;

      this.render = function() {
        var temp = parseFloat(this.stepData.temperature);
        temp = (temp < 100) ? temp.toFixed(1) : temp;

        this.text = new fabric.IText(temp +"º", {
          fill: 'black',
          fontSize: 20,
          top : this.parent.top + 10,
          left: this.parent.left - 15,
          fontFamily: "dinot-bold",
          selectable: false,
          hasBorder: false
        });

      };

      this.render();

      this.text.on('editing:exited', function() {
        console.log(editMode);
        parent.createNewStepDataGroup();
      });

      return this.text;
    };
  }
]);
