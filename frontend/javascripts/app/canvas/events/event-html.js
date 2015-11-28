window.ChaiBioTech.ngApp.factory('htmlEvents', [
  'ExperimentLoader',
  'previouslySelected',
  'previouslyHoverd',
  'scrollService',
  'popupStatus',

  function(ExperimentLoader, previouslySelected, previouslyHoverd, scrollService, popupStatus) {

    this.init = function(C, $scope, that) {

      angular.element('body').click(function(evt) {

        if(popupStatus.popupStatusAddStage && evt.target.id != "add-stage") {
            angular.element('#add-stage').click();
        }

      });

      angular.element('.canvas-container, .canvasClass').mouseleave(function() {

        if(C.editStageStatus === false) {
            if(previouslyHoverd.step) {
              previouslyHoverd.step.closeImage.setVisible(false);
            }
            previouslyHoverd.step = null;
            C.canvas.renderAll();
        }
      });

      angular.element('.canvas-containing').click(function(evt) {

        if(evt.target == evt.currentTarget) {
          that.setSummaryMode();
        }
      });

    };
    return this;
  }
]);
