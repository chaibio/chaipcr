angular.module("canvasApp").service('stepTemperatureService', [
    'editMode',
    'ExperimentLoader',
    'moveRampLineService',
    'alerts',
    function(editMode, ExperimentLoader, moveRampLineService, alerts) {

        this.postEdit = function($scope, parent, textObject) {

            editMode.tempActive = false;
            editMode.currentActiveTemp = null;
            var tempFloat, tempNo = parseFloat(textObject.text.replace("º", ""));

            if(tempNo === 0) {
                tempFloat = 0;
            } else {
                tempFloat = Math.abs(parseFloat(textObject.text.replace("º", ""))) || $scope.step.temperature;
            }


            if($scope.step.hold_time >=7200 && tempFloat < 20){
                alerts.showMessage(alerts.holdLess20DurationWarning, $scope);
            } else {
                $scope.step.temperature = (tempFloat > 100) ? 100.0 :  tempFloat;
                ExperimentLoader.changeTemperature($scope).then(function(data) {
                    console.log("saved", data);
                });
            }

            parent.model.temperature = $scope.step.temperature;
            parent.circleGroup.top = parent.getTop().top;
            parent.createNewStepDataGroup();
            moveRampLineService.manageDrag(parent.circleGroup, true);
            parent.circleGroup.setCoords();
            parent.canvas.renderAll();
        };
    }
]);