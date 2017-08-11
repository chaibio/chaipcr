angular.module("canvasApp").service('stepHoldTimeService', [
    'editMode',
    'TimeService',
    'ExperimentLoader',
    'alerts',
    function(editMode, TimeService, ExperimentLoader, alerts) {

        this.formatHoldTime = function(hold_time) {
            return TimeService.newTimeFormatting(hold_time);
        };

        this.ifLastStep = function(step) {
            console.log("Lox", step)
            return step.parentStage.nextStage === null && step.nextStep === null;
        };

        // Defrag this method.. 
        this.postEdit = function($scope, parent, textObject) {
            // There is some issues for, saving new hold_time for infinite hold, make sure uts corrected when new design comes.
            editMode.holdActive = false;
            editMode.currentActiveHold = null;
            var previousHoldTime = Number($scope.step.hold_time);
            var newHoldTime = Number(TimeService.convertToSeconds(textObject.text));


            if(! isNaN(newHoldTime) && (newHoldTime !== previousHoldTime)) { //Should unify this with step-hold-time-directives
                if(newHoldTime < 0) {
                    alerts.showMessage(alerts.noNegativeHold, $scope);
                } else if(newHoldTime === 0) {
                    if(this.ifLastStep(parent.parent) && ! $scope.step.collect_data) {
                        $scope.step.hold_time = newHoldTime;
                        ExperimentLoader.changeHoldDuration($scope).then(function(data) {
                            console.log("saved", data);
                        });
                    } else {
                        alerts.showMessage(alerts.holdDurationZeroWarning, $scope);
                    }
                } else {
                    $scope.step.hold_time = newHoldTime;
                    ExperimentLoader.changeHoldDuration($scope).then(function(data) {
                        console.log("saved", data);
                    });
                }
            }

            parent.model.hold_time = $scope.step.hold_time;
            parent.createNewStepDataGroup();
            if(this.ifLastStep(parent.parent)) {
                parent.doThingsForLast(newHoldTime, previousHoldTime);
            }
            parent.canvas.renderAll();

        };
    }
]);