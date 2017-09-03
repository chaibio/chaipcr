angular.module("canvasApp").service('stepTemperatureService', [
    'editMode',
    'ExperimentLoader',
    'moveRampLineService',
    function(editMode, ExperimentLoader, moveRampLineService) {

        this.postEdit = function($scope, parent, textObject) {

            editMode.tempActive = false;
            editMode.currentActiveTemp = null;
            var tempFloat, tempNo = parseFloat(textObject.text.replace("º", ""));


            if(tempNo === 0) {
                tempFloat = 0;
            } else {
                tempFloat = Math.abs(parseFloat(textObject.text.replace("º", ""))) || $scope.step.temperature;
            }

            $scope.step.temperature = (tempFloat > 100) ? 100.0 :  tempFloat;

            ExperimentLoader.changeTemperature($scope).then(function(data) {
                console.log("saved", data);
            });

            parent.model.temperature = $scope.step.temperature;
            parent.circleGroup.top = parent.getTop().top;
            parent.createNewStepDataGroup();
            moveRampLineService.manageDrag(parent.circleGroup);
            parent.circleGroup.setCoords();
            parent.canvas.renderAll();
        };
    }
]);