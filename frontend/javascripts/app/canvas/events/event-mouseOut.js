window.ChaiBioTech.ngApp.factory('mouseOut', [
  'ExperimentLoader',
  'previouslySelected',
  'previouslyHoverd',
  'scrollService',
  function(ExperimentLoader, previouslySelected, previouslyHoverd, scrollService) {

    this.init = function(C, $scope, that) {

      var me;
      this.canvas.on("mouse:out", function(evt) {
        if(! evt.target) return false;

        switch(evt.target.name) {

          case "stepGroup":
            // May be we need something in here
          break;
          case "controlCircleGroup":
            that.canvas.hoverCursor = "move";
          break;
          case "deleteStepButton":
            that.canvas.hoverCursor = "move";
          break;
        }
      });
    };
    return this;
  }
]);
