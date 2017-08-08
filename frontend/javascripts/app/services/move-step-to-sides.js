window.ChaiBioTech.ngApp.service('moveStepToSides', [
    function() {
        this.moveToSide = function(step, direction) {

            if(direction === "left" && step.stepMovedDirection !== "left") {
                step.left = step.left - 10;
                step.moveStep(0, false);
                step.circle.moveCircleWithStep();
                step.stepMovedDirection = "left";
            } else if(direction === "right" && step.stepMovedDirection !== "right") {
                step.left = step.left + 10;
                step.moveStep(0, false);
                step.circle.moveCircleWithStep();
                step.stepMovedDirection = "right";
            }
      };
    }
]);