window.ChaiBioTech.ngApp.service('stepDataGroupService', [
    'stepDataGroup',
    'stepTemperature',
    'stepHoldTime',
    function(stepDataGroup, stepTemperature, stepHoldTime) {

        this.newStepDataGroup = function(circle, $scope) {
            
            circle.stepDataGroup = new stepDataGroup([
                circle.temperature = new stepTemperature(circle.model, circle, $scope),
                circle.holdTime = new stepHoldTime(circle.model, circle, $scope)
            ], circle, $scope);
            
        };

        this.reCreateNewStepDataGroup = function(circle, $scope) {

                circle.canvas.remove(circle.temperature);
                circle.canvas.remove(circle.holdTime);

                delete(circle.temperature);
                delete(circle.holdTime);

                this.newStepDataGroup(circle, $scope);
                
                circle.canvas.add(circle.stepDataGroup);
                circle.canvas.renderAll();
        };
    } 
]);
