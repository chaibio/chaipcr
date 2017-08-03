window.ChaiBioTech.ngApp.service('addStepService', [
    'constants',
    'correctNumberingService',
    'step',
    'circleManager',
    function(constants, correctNumberingService, step, circleManager) {

        /*
        @stage , at which stage this step is going to be added
        @stepData datra of the new step being created
        @currentStep,  Step which is already selected. null if we are going to add at the beginning of the stage. 
        @scope , angular scope.
        */
        this.addNewStep = function(stage, stepData, currentStep, $scope) {

            
            stage.setNewWidth(constants.stepWidth); // Increase the width of the stage
            stage.moveAllStepsAndStages(false); // Move other stages away
            
            var index = 0;
            var start = (currentStep) ? currentStep.index : 0;
            var newStep = new step(stepData.step, stage, start, $scope); // Creates a new step

            newStep.name = "I am created";
            newStep.render();
            newStep.ordealStatus = (currentStep) ? currentStep.ordealStatus : stage.childSteps[0].ordealStatus;
            
            if(currentStep) {
                index = currentStep.index + 1;
            } else {
                index = 0;
            }

            stage.childSteps.splice(index, 0, newStep);
            stage.model.steps.splice(index, 0, stepData);
            
            stage.configureStep(newStep, start);
            stage.parent.allStepViews.splice(newStep.ordealStatus, 0, newStep);

            correctNumberingService.correctNumbering();
            newStep.circle.moveCircle();
            newStep.circle.getCircle();

            circleManager.addRampLines();
            stage.stageHeader();
            $scope.applyValues(newStep.circle);
            newStep.circle.manageClick(true);
            stage.parent.setDefaultWidthHeight();

        };
    }
]);