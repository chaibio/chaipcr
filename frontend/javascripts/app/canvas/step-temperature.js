angular.module("canvasApp").factory('stepTemperature', [
  'editMode',
  'ExperimentLoader',
  function(editMode, ExperimentLoader) {
    return function(model, parent, $scope) {

      this.model = model;
      this.parent = parent;
      this.canvas = parent.canvas;
      this.stepData = this.model;
      var that = this;

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
          hasBorder: false,
          type: "temperatureDisplay"
        });

      };

      this.render();

      this.text.on('text:editing:exited', function() {
        // This block is executed when we hit enter.
        // This condition is a tricky one. When we hit enter text:editing:exited and editing:exited are called and
        // we dont need to execute twice. So in the first call, whichever it is editMode.tempActive is made false.
        if(editMode.tempActive) {
          that.postEdit();
        }

      });

      this.text.on('editing:exited', function() {
        // This block works when we click somewhere else after enabling inline edit.
        if(editMode.tempActive) {
          that.postEdit();
        }
      });

      this.postEdit = function() {

        editMode.tempActive = false;
        var tempFloat = Math.abs(parseFloat(this.text.text.replace("º", ""))) || $scope.step.temperature;
        $scope.step.temperature = (tempFloat > 100) ? 100.0 :  tempFloat;

        ExperimentLoader.changeTemperature($scope).then(function(data) {
          console.log("saved", data);
        });
        parent.model.temperature = $scope.step.temperature;
        parent.circleGroup.top = parent.getTop().top;
        parent.createNewStepDataGroup();
        parent.manageDrag(parent.circleGroup);
        parent.circleGroup.setCoords();
        parent.canvas.renderAll();
      };
      return this.text;
    };
  }
]);
