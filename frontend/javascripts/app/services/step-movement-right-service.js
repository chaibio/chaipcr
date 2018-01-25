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

window.ChaiBioTech.ngApp.service('StepMovementRightService', [
    'StepPositionService',
    'moveStepToSides',
    function(StepPositionService, moveStepToSides) {
        return {

            ifOverRightSide: function(stepIndicator) {
                stepIndicator.movedStepIndex = null;

                StepPositionService.allPositions.some(this.ifOverRightSideCallback, stepIndicator);
                return stepIndicator.movedStepIndex;
            },

            ifOverRightSideCallback: function(points, index) {
                // Note , this method works in the context of stepIndicator, dont confuse with this keyword.
                var edge = this.movement.left + this.rightOffset;
                if(edge > points[1] && edge < points[2]) {
                    console.log("Alright");
                    if(index !== this.currentMoveRight) {
                        moveStepToSides.moveToSide(this.kanvas.allStepViews[index], "left");
                        this.currentMoveRight = this.movedStepIndex = index;
                        StepPositionService.getPositionObject(this.kanvas.allStepViews);
                    }
                    return true;
                }
            },

            movedRightAction: function(stepIndicator) {
                
                stepIndicator.currentDrop = stepIndicator.kanvas.allStepViews[stepIndicator.movedStepIndex];
                stepIndicator.currentDropStage = stepIndicator.currentDrop.parentStage;
                this.manageVerticalLineRight(stepIndicator);
                this.manageBorderLeftForRight(stepIndicator);
                stepIndicator.currentMoveLeft = null; // Resetting
            },

            manageVerticalLineRight: function(si) {
                
                var index = si.movedStepIndex;
                var place = (si.kanvas.allStepViews[index].left + si.kanvas.allStepViews[index].myWidth - 2);
                
                if(si.kanvas.allStepViews[index].nextIsMoving === true) {
                    place = si.kanvas.moveDots.left + 7;
                }
                si.verticalLine.setLeft(place);
                console.log("done");
                si.verticalLine.setCoords();
            },

            manageBorderLeftForRight: function(sI) {
                
                var index = sI.movedStepIndex;
                
                if(sI.kanvas.allStepViews[index].nextStep) {
                    sI.kanvas.allStepViews[index + 1].borderLeft.setVisible(true);
                }
                
                if(sI.kanvas.allStepViews[index].index === 0) {
                    sI.kanvas.allStepViews[index].borderLeft.setVisible(true);
                } else {
                    sI.kanvas.allStepViews[index].borderLeft.setVisible(false);
                }     
                
            }
        };
    }
]);
