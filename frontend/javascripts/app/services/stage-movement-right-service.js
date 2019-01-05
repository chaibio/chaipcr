/*
 * Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
 * For more information visit http://www.chaibio.com
 *
 * Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

window.ChaiBioTech.ngApp.service('StageMovementRightService', [
    'StepPositionService',
    'StagePositionService',
    'moveStageToSidesWhileMoveStep',
    function(StepPositionService, StagePositionService, moveStageToSidesWhileMoveStep) {
        return {

            shouldStageMoveRight: function(sI) {
                sI.movedStageIndex = null;
                StagePositionService.allPositions.some(this.shouldStageMoveRightCallback, sI);
                return sI.movedStageIndex;
            },

            shouldStageMoveRightCallback: function(point, index) {
                
                if((this.movement.referencePoint) > point[0] - 60 && (this.movement.referencePoint) < point[0]) {
                    
                    
                    if(index !== this.movedRightStageIndex) {
                        console.log("LX");
                        this.movedStageIndex = this.movedRightStageIndex = index;
                        moveStageToSidesWhileMoveStep.moveToSideForStep("right", this.kanvas.allStageViews[index], this);
                        StagePositionService.getPositionObject();
                        StagePositionService.getAllVoidSpaces();
                        StepPositionService.getPositionObject(this.kanvas.allStepViews);
                        return true;
                    } /*else if((this.movement.referencePoint) > point[0] - 140 && (this.movement.referencePoint) < point[0] - 100) {
                       //this.movedStageIndex = this.movedLeftStageIndex = index;
                        console.log("Hotcha");
                        moveStageToSidesWhileMoveStep.moveStageToLeftSpecialCase(this.kanvas.allStageViews[index]); 
                        this.kanvas.stepIndicator.headerExtender.setVisible(false);
                        StagePositionService.getPositionObject();
                        StagePositionService.getAllVoidSpaces();
                        StepPositionService.getPositionObject(this.kanvas.allStepViews);
                        return true;
                    }*/
                }
                
            }
        };
    }
]);
