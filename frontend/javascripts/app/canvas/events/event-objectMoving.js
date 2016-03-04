angular.module("canvasApp").factory('objectMoving', [
  'ExperimentLoader',
  'previouslySelected',
  'previouslyHoverd',
  'scrollService',
  function(ExperimentLoader, previouslySelected, previouslyHoverd, scrollService) {

    /**************************************
        Here we write what happens when we drag over the canvas.
        here too we look for the target in the event and do the action.
    ***************************************/
    this.init = function(C, $scope, that) {

      var me;
      this.canvas.on('object:moving', function(evt) {
        if(! evt.target) return false;

        switch(evt.target.name) {

          case "controlCircleGroup":
            me = evt.target.me;
            me.manageDrag(evt.target);
            $scope.$apply(function() {
              $scope.step.temperature = me.model.temperature;
            });
          break;

          case "moveStep":
            if(evt.target.left < 35) {
              evt.target.setLeft(35);
              that.onTheMoveDragGroup(evt.target);
            } else if(evt.target.left > C.moveLimit) {
              evt.target.setLeft(C.moveLimit);
              that.onTheMoveDragGroup(evt.target);
            } else {
              that.onTheMoveDragGroup(evt.target);
              C.stepIndicator.onTheMove(C);
            }

          break;
        }
      });
    };
    return this;
  }
]);
