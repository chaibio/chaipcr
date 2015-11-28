window.ChaiBioTech.ngApp.factory('mouseDown', [
  'ExperimentLoader',
  'previouslySelected',
  'previouslyHoverd',
  'scrollService',
  function(ExperimentLoader, previouslySelected, previouslyHoverd, scrollService) {

    /**************************************
        what happens when click is happening in canvas.
        what we do is check if the click is up on some particular canvas element.
        and we send the changes to angular directives.
    ***************************************/
    
    this.init = function(C, $scope, that) {

      var me;

      this.canvas.on("mouse:down", function(evt) {

        if(! evt.target) {
          that.setSummaryMode();
          return false;
        }
        that.mouseDown = true;

        switch(evt.target.name)  {

          case "stepGroup":

            me = evt.target.me;
            that.selectStep(me.circle);
          break;

          case "controlCircleGroup":

            me = evt.target.me;
            that.selectStep(me);
          break;

          case "deleteStepButton":

            me  = evt.target.me;
            that.selectStep(me.circle);
            ExperimentLoader.deleteStep($scope)
            .then(function(data) {
              console.log("deleted", data);
              me.parentStage.deleteStep({}, me);
              C.canvas.renderAll();
            });
          break;
        }

      });
    };
    return this;
  }
]);
