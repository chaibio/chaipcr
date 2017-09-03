window.ChaiBioTech.ngApp.service('addStageService', [
    'constants',
    'correctNumberingService',
    'stage',
    'circleManager',
    function(constants, correctNumberingService, stage, circleManager) {
        
        this.canvasObj = null;

        this.init = function(canvasObj) {
            this.canvasObj = canvasObj;
        };

        this.addNewStage = function(data, currentStage, mode) {

            //move the stages, make space.
            var ordealStatus = currentStage.childSteps[currentStage.childSteps.length - 1].ordealStatus;
            var originalWidth = currentStage.myWidth;
            var add = (data.stage.steps.length > 0) ? 128 + Math.floor(constants.newStageOffset / data.stage.steps.length) : 128;

            currentStage = this.makeSpaceForNewStage(data, currentStage, add);
            // okay we puhed stages in front by inflating the current stage and put the old value back.
            currentStage.myWidth = originalWidth;

            // now create a stage;
            var stageIndex = currentStage.index + 1;
            var stageView = new stage(data.stage, this.canvasObj, stageIndex, true, this.canvasObj.$scope);

            this.addNextandPrevious(currentStage, stageView);
            stageView.updateStageData(1);
            this.canvasObj.allStageViews.splice(stageIndex, 0, stageView);
            stageView.render();
            // configure steps;
            this.insertStageGraphics(stageView, ordealStatus, mode);
        };

        this.makeSpaceForNewStage = function(data, currentStage, add) {

            data.stage.steps.forEach(function(step) {
                currentStage.myWidth = currentStage.myWidth + add;
                currentStage.moveAllStepsAndStages(false);
            });
            return currentStage;
        };

        this.addNextandPrevious = function(currentStage, stageView) {

            if(currentStage) {
                if(currentStage.nextStage) {
                    stageView.nextStage = currentStage.nextStage;
                    stageView.nextStage.previousStage = stageView;
                }
                currentStage.nextStage = stageView;
                stageView.previousStage = currentStage;
            } else if (! currentStage) { // if currentStage is null, It means we are inserting at very first
                stageView.nextStage = this.canvasObj.allStageViews[0];
                this.canvasObj.allStageViews[0].previousStage = stageView;
            }
        };

        this.insertStageGraphics = function(stageView, ordealStatus, mode) {

            this.configureStepsofNewStage(stageView, ordealStatus);
            correctNumberingService.correctNumbering();

            if(mode === "move_stage_back_to_original") {
                console.log("YES ", mode);
                this.canvasObj.allStageViews[0].getLeft();
            }
            
            this.canvasObj.allStageViews[0].moveAllStepsAndStages(false);
            circleManager.addRampLines();
            stageView.stageHeader();
            this.canvasObj.$scope.applyValues(stageView.childSteps[0].circle);
            stageView.childSteps[0].circle.manageClick(true);
            this.canvasObj.setDefaultWidthHeight();
        };

        this.addNewStageAtBeginning = function(data) {

            var add = (data.stage.steps.length > 0) ? 128 + Math.floor(constants.newStageOffset / data.stage.steps.length) : 128;
            var stageIndex = 0;
            var stageView = new stage(data.stage, this.canvasObj, stageIndex, true, this.canvasObj.$scope);

            this.addNextandPrevious(null, stageView);
            this.canvasObj.allStageViews.splice(stageIndex, 0, stageView);

            stageView.updateStageData(1);
            stageView.render();
            this.insertStageGraphics(stageView, 0, "add_stage_at_beginning");
            
        };

        this.configureStepsofNewStage = function(stageView, ordealStatus) {

            stageView.childSteps.forEach(function(step) {

                step.ordealStatus = ordealStatus + 1;
                step.render();
                //Important
                step.circle.moveCircle();
                step.circle.getCircle();
                //
                this.canvasObj.allStepViews.splice(ordealStatus, 0, step);
                ordealStatus = ordealStatus + 1;
            }, this);
        };
    }
]);