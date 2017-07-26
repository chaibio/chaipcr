window.ChaiBioTech.ngApp.service('correctNumberingService', [
    function() {
        this.canvasObj = null;
        
        this.init = function(obj) {
            this.canvasObj = obj;
        };

        this.correctNumbering = function() {

            this.oStatus = 1;
            this.tempCircle = null;
            this.canvasObj.allStepViews = [];
            this.canvasObj.allStageViews.forEach(this.correctNumberingStage, this);
        };

        this.correctNumberingStage = function(stage, index) {

            stage.stageMovedDirection = null;
            //stage.sourceStage = false;
            stage.index = index;
            stage.stageCaption.setText("STAGE " + (index + 1) + ": " );
            stage.childSteps.forEach(this.correctNumberingStep, this);
        };

        this.correctNumberingStep = function(step, index) { 

            if(this.tempCircle) {
                this.tempCircle.next = step.circle;
                step.circle.previous = this.tempCircle;
            } else {
                step.circle.previous = null;
            }

            this.tempCircle = step.circle;
            step.index = index;
            // A quick fix, will be removed later
            step.borderLeft.setVisible(false);
            step.stepMovedDirection = null;
            step.nextIsMoving = step.previousIsMoving = null;
            step.ordealStatus = this.oStatus;
            this.canvasObj.allStepViews.push(step);
            this.oStatus = this.oStatus + 1;

        };

    }
]);