window.ChaiBioTech.ngApp.service('pauseStepService', [

    function() {

        this.applyPauseChanges = function(circleGroup) {

            circleGroup.circle.setFill("#ffb400");
            circleGroup.circle.setStroke("#ffde00");
            circleGroup.circle.strokeWidth = 4;
            circleGroup.circle.radius = 13;
            circleGroup.pauseImageMiddle.setVisible(true);
            circleGroup.gatherDataImageMiddle.setVisible(false);
            circleGroup.pauseStepOnScrollGroup.setVisible(false);
      };

      this.controlPause = function(circleGroup) {

            var state = circleGroup.model.pause;
            
            if(state && circleGroup.big) {
                circleGroup.pauseStepOnScrollGroup.setVisible(true);
                circleGroup.holdTime.setVisible(false);
            } else if(state) {
                circleGroup.holdTime.setVisible(false);
                this.applyPauseChanges(circleGroup);
            } else {
                circleGroup.pauseStepOnScrollGroup.setVisible(false);
                circleGroup.holdTime.setVisible(true);
            }
      };

    }
]);