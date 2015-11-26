window.ChaiBioTech.ngApp.factory('objectMoving', [
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
            var targetCircleGroup = evt.target,
            me = evt.target.me;
            me.manageDrag(targetCircleGroup);
            $scope.$apply(function() {
              $scope.step.temperature = me.model.temperature;
            });
          break;

          case "dragStepGroup":
            that.onTheMoveDragGroup(evt.target);
          break;

          case "dragStageGroup":
            that.onTheMoveDragGroup(evt.target);
          break;

        }
      });
    };
    return this;
  }
]);
