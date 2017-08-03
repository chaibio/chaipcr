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

            stage.setNewWidth(constants.stepWidth);
            stage.moveAllStepsAndStages();

            var start = currentStep.index || 0;
            var newStep = new step(stepData.step, stage, start, $scope);
            newStep.name = "I am created";
            newStep.render();
            newStep.ordealStatus = currentStep.ordealStatus || stage.childSteps[0].ordealStatus;

            stage.childSteps.splice(newStep.index, 0, newStep);
            stage.model.steps.splice(newStep.index, 0, data);
            stage.configureStep(newStep, start);
            stage.parent.allStepViews.splice(currentStep.ordealStatus, 0, newStep);

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