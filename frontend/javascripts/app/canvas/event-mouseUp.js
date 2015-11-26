window.ChaiBioTech.ngApp.factory('mouseUp', [
  'ExperimentLoader',
  'previouslySelected',
  'previouslyHoverd',
  'scrollService',
  function(ExperimentLoader, previouslySelected, previouslyHoverd, scrollService) {

    this.init = function(C, $scope, that) {

      this.canvas.on("mouse:up", function(evt) {

        if(that.mouseDown) {
          that.canvas.defaultCursor = "default";
          that.startDrag = 0;
          that.mouseDown = false;
        }
      });
    };
    return this;
  }
]);
