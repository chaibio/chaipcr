window.ChaiBioTech.ngApp.service('editModeService', [
    'previouslySelected',
    function(previouslySelected) {

        this.canvasObj = null;
        this.status = null;

        this.init = function(obj) {
            this.canvasObj = obj;
        };

        this.editStageMode = function(status) {
            
            var add = (status) ? 25 : -25;
            this.status = status;

            if(status === true) {
                this.canvasObj.editStageStatus = status;
                previouslySelected.circle.parent.manageFooter("black");
                previouslySelected.circle.parent.parentStage.changeFillsAndStrokes("black", 4);
            } else {
                previouslySelected.circle.parent.manageFooter("white");
                previouslySelected.circle.parent.parentStage.changeFillsAndStrokes("white", 2);
                this.canvasObj.editStageStatus = status; 
                //This order editStageStatus is changed is important, because changeFillsAndStrokes()
            }

            // Rewrite part for one stage one step Scenario.
            var count = this.canvasObj.allStageViews.length - 1;
            
            this.canvasObj.allStageViews.forEach(function(stage, index) {
                this.editStageModeStage(stage, add, count, index);
            }, this);

            this.canvasObj.canvas.renderAll();
        };

        this.editStageModeStage = function(stage, add, count, stageIndex) {

            if(stageIndex === count) {

                var lastStep = stage.childSteps[stage.childSteps.length - 1];
                if(parseInt(lastStep.circle.model.hold_time) !== 0) {
                    this.canvasObj.editModeStageChanges(stage, add, this.status);
                }
            } else {
                this.canvasObj.editModeStageChanges(stage, add, this.status);
            }

            stage.childSteps.forEach(function(step, index) {
                this.canvasObj.editStageModeStep(step, this.status);
            }, this);
        };
    }
]);