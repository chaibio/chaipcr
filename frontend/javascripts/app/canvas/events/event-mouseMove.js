window.ChaiBioTech.ngApp.factory('mouseMove', [
  'ExperimentLoader',
  'previouslySelected',
  'previouslyHoverd',
  'scrollService',
  function(ExperimentLoader, previouslySelected, previouslyHoverd, scrollService) {

    this.init = function(C, $scope, that) {

      var me, left, canvasContaining = $('.canvas-containing'), startPos;

      this.canvas.on("mouse:move", function(evt) {

        if(that.mouseDown && evt.target) {

          if(that.startDrag === 0) {
            that.canvas.defaultCursor = "move";
            that.startDrag = evt.e.clientX;
            startPos = canvasContaining.scrollLeft();
          }

          left = startPos + (evt.e.clientX - that.startDrag);

          if((left >= 0) && (left <= $scope.scrollWidth - 1024)) {

            $scope.$apply(function() {
              $scope.scrollLeft = left;
            });

            canvasContaining.scrollLeft(left);
          }
        }
      });
    };
    return this;
  }
]);
