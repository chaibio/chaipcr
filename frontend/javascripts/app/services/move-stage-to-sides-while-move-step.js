window.ChaiBioTech.ngApp.service('moveStageToSidesWhileMoveStep', [
    'moveStageToSides',
    function(moveStageToSides) {
        
        this.moveToSideForStep = function(direction, targetStage) {

            if(direction === "left") {
                this.moveStageToLeft(targetStage);
            } else if(direction === "right") {
                this.moveStageToRight(targetStage);
            }
        };

        this.moveStageToRight = function(stage) {
            
            while(stage) {
                if(stage.stageMovedDirection !== 'right') {
                    moveStageToSides.moveToSideStageComponents(30, stage);
                    stage.stageMovedDirection = "right";
                } else if(stage.stageMovedDirection === "right") {
                    break;
                }
                stage = stage.nextStage;
            }
        };

        this.moveStageToLeft = function(stage) {
            console.log("dvdf");
            //while(stage) {
            if(stage.stageMovedDirection === null && stage.nextStage) {
                this.moveStageToRight(stage.nextStage);
                //break;
            } else if(stage.stageMovedDirection === "left") {
                this.moveStageToRight(stage.nextStage);
                //break;
            } else if(stage.stageMovedDirection !== "left") {
                moveStageToSides.moveToSideStageComponents(-30, stage);
                stage.stageMovedDirection = "left";
                //break;
            } 
                //stage = stage.previousStage;
            //}
        };

        this.moveStageToLeftSpecialCase = function(stage) {

            while(stage) {
                if(stage.stageMovedDirection === "right") {
                    moveStageToSides.moveToSideStageComponents(-30, stage);
                    stage.stageMovedDirection = "left";
                }
                stage = stage.nextStage;
            }
        };
    }
]);