window.ChaiBioTech.ngApp.service('editModeService', [
    'previouslySelected',
    function(previouslySelected) {

        this.canvasObj = null;
        this.status = null;

        this.init = function(obj) {
            this.canvasObj = obj;
        };

        this.editStageMode = function(status) {
            
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
                this.editStageModeStage(stage, count, index);
            }, this);

            this.canvasObj.canvas.renderAll();
        };

        this.editStageModeStage = function(stage, count, stageIndex) {

            if(stageIndex === count) {

                var lastStep = stage.childSteps[stage.childSteps.length - 1];
                if(parseInt(lastStep.circle.model.hold_time) !== 0) {
                    this.editModeStageChanges(stage);
                }
            } else {
                this.editModeStageChanges(stage);
            }

            stage.childSteps.forEach(function(step, index) {
                this.editStageModeStep(step);
            }, this);
        };

        this.editModeStageChanges = function(stage) {

            var leftVal = {};
            stage.dots.setVisible(this.status);
            stage.dots.setCoords();
            this.canvasObj.canvas.bringToFront(stage.dots);
            
            if(this.status === true) {

                if(stage.stageNameGroup.moved !== "right") {
                    leftVal = {left: stage.stageNameGroup.left + 26};
                    stage.stageNameGroup.set(leftVal);
                    stage.stageNameGroup.setCoords();
                    stage.stageNameGroup.moved = "right";
                }
                if(stage.childSteps.length === 1) {
                    stage.shortenStageName();
                }
            } else if(this.status === false) {
                if(stage.stageNameGroup.moved === "right") {
                    leftVal = {left: stage.stageNameGroup.left - 26};
                    stage.stageNameGroup.set(leftVal);
                    stage.stageNameGroup.setCoords();
                    stage.stageNameGroup.moved = false;
                }
                stage.stageHeader();
            }
        };

        this.temporaryChangeForStatus = function(tempStat, stage) {

            var keepStat = this.status;
            this.status = tempStat;
            this.editModeStageChanges(stage);
            this.status = keepStat;
        };
        
        this.editStageModeStep = function(step) {

            step.closeImage.setOpacity(this.status);

            if(step.model.hold_time === 0) {
                step.dots.setVisible(false);
            } else {
                step.dots.setVisible(this.status);
            }
            
            step.dots.setCoords();

            if( step.parentStage.model.auto_delta ) {
                if( step.index === 0 ) {
                    step.deltaSymbol.setVisible(!this.status);
                }
                step.deltaGroup.setVisible(!this.status);
            }
        };
    }
]);