window.ChaiBioTech.ngApp.service('moveStageToSidesWhileMoveStep', [
    'moveStageToSides',
    function(moveStageToSides) {
        
        this.moveToSideForStep = function(direction, targetStage, sI) {

            if(direction === "left") {
                this.moveStageToLeft(targetStage, sI);
            } else if(direction === "right") {
                this.moveStageToRight(targetStage, sI);
            }
        };

        this.moveStageToRight = function(stage, sI) {
            console.log(sI);
            if(stage.previousStage === null) {
                return null;
            }
                
            var altered = false;
            while(stage) {
                if(stage.stageMovedDirection !== 'right') {
                //if(stage.partialMove) {
                    //  moveStageToSides.moveToSideStageComponents(24, stage);
                    // stage.partialMove = false;
                //} else {
                    moveStageToSides.moveToSideStageComponents(30, stage);
                //}
                    stage.stageMovedDirection = "right";
                    if(altered === false) {
                        sI.emptySpaceTrackerForStage = {
                            left: stage.previousStage.index,
                            right: stage.index
                        };
                        altered = true;
                    }
                    

                } else if(stage.stageMovedDirection === "right") {
                    break;
                }
                stage = stage.nextStage;
            }

            
        };

        this.moveStageToLeft = function(stage, sI) {
            
            //while(stage) {
            if(stage.stageMovedDirection === null && stage.nextStage) {
                this.moveStageToRight(stage.nextStage, sI);
                //break;
            } else if(stage.stageMovedDirection === "left") {
                this.moveStageToRight(stage.nextStage, sI);
                //break;
            } else if(stage.stageMovedDirection !== "left") {
                moveStageToSides.moveToSideStageComponents(-30, stage);
                stage.stageMovedDirection = "left";
                
                sI.emptySpaceTrackerForStage = {
                    left: stage.index,
                    right: (stage.nextStage) ? stage.nextStage.index : null
                };
                //break;
            } 
                //stage = stage.previousStage;
            //}
        };

        this.moveStageToLeftSpecialCase = function(stage, sI) {

            while(stage) {
                if(stage.previousStage /*&& stage.previousStage.stageMovedDirection === "left" */) {
                    if(stage.stageMovedDirection === "right") {
                        moveStageToSides.moveToSideStageComponents(-30, stage);
                        stage.stageMovedDirection = "left";
                        //stage.partialMove = true;
                    }
                }
                
                stage = stage.nextStage;
            }
        };
    }
]);