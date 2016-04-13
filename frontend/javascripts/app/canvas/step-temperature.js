angular.module("canvasApp").factory('stepTemperature', [
  'editMode',
  'ExperimentLoader',
  function(editMode, ExperimentLoader) {
    return function(model, parent, $scope) {

      this.model = model;
      this.parent = parent;
      this.canvas = parent.canvas;
      this.stepData = this.model;
      //this.lockUpdate = false;
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
          hasBorder: false
        });

      };

      this.render();



      this.text.on('text:editing:exited', function() {
        console.log("block 1");
        if(editMode.tempActive) {
          that.postEdit();
        }

      });

      this.text.on('editing:exited', function() {
        console.log("block 2");
        if(editMode.tempActive) {
          that.postEdit();
        }
      });

      this.postEdit = function() {

        editMode.tempActive = false;
        $scope.step.temperature = parseFloat(this.text.text.replace("º", "")) || 0;
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
