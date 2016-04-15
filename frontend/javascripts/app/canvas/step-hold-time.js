angular.module("canvasApp").factory('stepHoldTime', [
  'editMode',
  'ExperimentLoader',
  'alerts',
  function(editMode, ExperimentLoader, alerts) {
    return function(model, parent, $scope) {

      this.model = model;
      this.parent = parent;
      this.canvas = parent.canvas;
      var that = this;

      this.formatHoldTime = function() {

        var holdTimeHour = Math.floor(this.holdTime / 60);
        var holdTimeMinute = (this.holdTime % 60);

        holdTimeMinute = (holdTimeMinute < 10) ? "0" + holdTimeMinute : holdTimeMinute;

        return holdTimeHour + ":" + holdTimeMinute;
      };

      this.render = function() {

        this.holdTime = this.model.hold_time;

        this.text = new fabric.IText(this.formatHoldTime(), {
          fill: 'black',
          fontSize: 20,
          top : this.parent.top + 10,
          left: this.parent.left + 40,
          fontFamily: "dinot",
          selectable: false,
          hasBorder: false,
          type: "holdTimeDisplay"
        });
      };

      this.render();

      this.text.on('text:editing:exited', function() {

        // This block is executed when we hit enter.
        // This condition is a tricky one. When we hit enter text:editing:exited and editing:exited are called and
        // we dont need to execute twice. So in the first call, whichever it is editMode.tempActive is made false.
        if(editMode.holdActive) {
          that.postEdit();
        }

      });

      this.text.on('editing:exited', function() {
        // This block works when we click somewhere else after enabling inline edit.
        if(editMode.holdActive) {
          that.postEdit();
        }
      });

      this.postEdit = function() {
        // There is some issues for, saving new hold_time for infinite hold, make sure uts corrected when new design comes.
        editMode.holdActive = false;
        $scope.step.hold_time = $scope.convertToMinute(this.text.text) || $scope.step.hold_time;

        if($scope.step.hold_time !== 0) { // If its zero server returns error , but make an exception for last step
          ExperimentLoader.changeHoldDuration($scope).then(function(data) {
            console.log("saved", data);
          });
        }

        parent.model.hold_time = $scope.step.hold_time;
        parent.createNewStepDataGroup();
        parent.canvas.renderAll();
      };

      return this.text;
    };
  }
]);
