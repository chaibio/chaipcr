window.ChaiBioTech.ngApp.service('moveRampLineService', [
    function() {
        // manage ramp line movement

        this.manageDrag = function(targetCircleGroup, isManual) {

          var top = targetCircleGroup.top;
          var left = targetCircleGroup.left;
          var parentCircle = targetCircleGroup.me;
          if(top < parentCircle.scrollTop) {
            targetCircleGroup.setTop(parentCircle.scrollTop);
            this.manageRampLineMovement(left, parentCircle.scrollTop, targetCircleGroup, parentCircle, isManual);
          } else if(top > parentCircle.lowestScrollCoordinate) {
            targetCircleGroup.setTop(parentCircle.lowestScrollCoordinate);
            this.manageRampLineMovement(left, parentCircle.scrollLength, targetCircleGroup, parentCircle, isManual);
          } else {
            parentCircle.stepDataGroup.setTop(top + 48).setCoords();
            this.manageRampLineMovement(left, top, targetCircleGroup, parentCircle, isManual);
          }
      };

      this.manageRampLineMovement = function(left, top, targetCircleGroup, parentCircle, isManual) {
        var midPointY;
        if(parentCircle.next) {

          midPointY = parentCircle.curve.nextOne(left, top);
          // We move the gather data Circle along with it [its next object's]
          parentCircle.next.gatherDataDuringRampGroup.setTop(midPointY);

          if(parentCircle.next.model.ramp.collect_data) {
            parentCircle.runAlongEdge();
          }
        }

        if(parentCircle.previous) {

          midPointY = parentCircle.previous.curve.previousOne(left, top);

          parentCircle.gatherDataDuringRampGroup.setTop(midPointY);

          if(parentCircle.model.ramp.collect_data) {
            parentCircle.runAlongCircle();
          }
        }

        parentCircle.temperatureDisplay(targetCircleGroup, isManual);
        parentCircle.parent.adjustRampSpeedPlacing();
      };

    }
]);