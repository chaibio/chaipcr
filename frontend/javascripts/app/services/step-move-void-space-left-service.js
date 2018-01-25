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

window.ChaiBioTech.ngApp.service('StepMoveVoidSpaceLeftService', [
    'StagePositionService',
    function(StagePositionService) {

        this.verticalLineForVoidLeft = function(sI, index) {
            console.log("Bingo");

            var tStep = sI.kanvas.allStageViews[index].childSteps[0];
            var place = sI.kanvas.allStageViews[index].left - 5;
            
            if(tStep.previousIsMoving) {
                place = sI.kanvas.moveDots.left + 7;
            }
            
            sI.currentDrop = null;
            sI.currentDropStage = sI.kanvas.allStageViews[index]; // We need to insert the step as the first.
            sI.verticalLine.setLeft(place);
            sI.verticalLine.setCoords();
            
            /*if(sI.rightOffset !== 96) {
                sI.rightOffset = 96; // When we click on the last step of a stage, we change rightOffset so that,
                // the condition in the voidSpaceCallbackLeft works, then we change it back.
            }*/
        };
        
        var that = this;

        return {
            outerScope: that,
            checkVoidSpaceLeft: function(sI) {
                StagePositionService.allVoidSpaces.some(this.voidSpaceCallbackLeft, sI);
            },

            voidSpaceCallbackLeft: function(point, index) {
                
                var abPlace = this.movement.left + this.rightOffset;
                if(point[1] - point[0] > 25 && abPlace > (point[0] + 25) && abPlace < point[1]) {
                    that.verticalLineForVoidLeft(this, index);
                    return true;
                }
            }

        };
    }
]);
