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

window.ChaiBioTech.ngApp.service('StageMovementLeftService', [
    'StepPositionService',
    'StagePositionService',
    'moveStageToSides',
    'moveStageToSidesWhileMoveStep',
    function(StepPositionService, StagePositionService, moveStageToSides, moveStageToSidesWhileMoveStep) {
        return {

            shouldStageMoveLeft: function(sI) {

                sI.movedStageIndex = null;
                StagePositionService.allPositions.some(this.shouldStageMoveLeftCallback, sI);
                return sI.movedStageIndex;
            },

            shouldStageMoveLeftCallback: function(point, index) {
                // Note, the context of this method is sI [stepIndicator]
                if((this.movement.left + this.rightOffset) > point[2] && (this.movement.left + this.rightOffset) < point[2] + 150) {
                    if(index !== this.movedLeftStageIndex) {
                        console.log("shoul move to left side");
                        this.movedStageIndex = this.movedLeftStageIndex = index;
                        moveStageToSidesWhileMoveStep.moveToSideForStep("left", {index: 10}, this.kanvas.allStageViews[index]); 
                        // {index: 10} is sent so that the very first stage doesnt move, refer stage.validMove()
                        // It dosnt have to be 10, can be any non zero value
                        StagePositionService.getPositionObject();
                        StagePositionService.getAllVoidSpaces();
                        StepPositionService.getPositionObject(this.kanvas.allStepViews);
                        return true;
                    }
                }
            }
        };
    }
]);
