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

window.ChaiBioTech.ngApp.service('StepMoveVoidSpaceRightService', [
    'StagePositionService',
    function(StagePositionService) {

       this.verticalLineForVoidRight = function(sI, index) {
           
            if(sI.kanvas.allStageViews[index - 1]) {
               
                var length = sI.kanvas.allStageViews[index - 1].childSteps.length;
                var tStep = sI.kanvas.allStageViews[index - 1].childSteps[length - 1];
                var place = tStep.left + tStep.myWidth;

                //console.log("fsd");
                /*sI.kanvas.allStageViews[index - 1].left + 
                            sI.kanvas.allStageViews[index - 1].myWidth - 5;*/
            
                if(tStep.nextIsMoving) {
                    place = sI.kanvas.moveDots.left + 7;
                }

                sI.currentDrop = sI.kanvas.allStageViews[index - 1].childSteps[length - 1];
                sI.currentDropStage = sI.kanvas.allStageViews[index - 1]; // We need to insert the step as the last.
                sI.verticalLine.setLeft(place);
                sI.verticalLine.setCoords();

                sI.verticalLine.borderS.setLeft(place + 14);
                sI.verticalLine.borderS.setCoords();
            }
            
        };
        
        var that = this;

        return {
            outerScope: that, // This is for testing verticalLineForVoidRight method which is private for StepMoveVoidSpaceRightService
            checkVoidSpaceRight: function(sI) {
                StagePositionService.allVoidSpaces.some(this.voidSpaceCallbackRight, sI);
            },

            voidSpaceCallbackRight: function(point, index) {
                // Context of this method is sI
                
                var abPlace = this.movement.left;
                if(point[1] - point[0] > 25 && abPlace > point[0] && abPlace < (point[1] - 25)) {
                    that.verticalLineForVoidRight(this, index);
                    return true;
                }
            },

        };
    }
]);
