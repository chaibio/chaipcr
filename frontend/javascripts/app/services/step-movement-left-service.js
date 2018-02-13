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

window.ChaiBioTech.ngApp.service('StepMovementLeftService', [
    'StepPositionService',
    'moveStepToSides',
    function(StepPositionService, moveStepToSides) {
        
        return {

            ifOverLeftSide: function(stepIndicator) {
                console.log("White box moving left");
                stepIndicator.movedStepIndex = null;
                StepPositionService.allPositions.some(this.ifOverLeftSideCallback, stepIndicator);
                return stepIndicator.movedStepIndex;
            },

            ifOverLeftSideCallback: function(points, index) {
                
                if((this.movement.referencePoint) > points[0] && (this.movement.referencePoint) < points[1]) {

                    if(this.currentMoveLeft !== index) {
                        this.currentMouseOver.exitDirection = "left";
                        moveStepToSides.moveToSide(this.kanvas.allStepViews[index], "right", this.currentMouseOver);
                        this.currentMoveLeft = this.movedStepIndex = index;
                        StepPositionService.getPositionObject(this.kanvas.allStepViews);
                    }
                return true;
                } else if(this.movement.referencePoint > points[1] && this.movement.referencePoint < points[2]) {

                    if(index !== this.currentMouseOver.index) {
                        this.currentMouseOver = {
                            index: index,
                            enterDirection: "right",
                            exitDirection: null,
                        };
                    }
                }
            },

            movedLeftAction: function(sI) {

                var step = sI.kanvas.allStepViews[sI.movedStepIndex];
                
                if(step.previousStep) {
                    sI.currentDrop = step.previousStep;
                    sI.currentDropStage = sI.currentDrop.parentStage;
                } else {
                    sI.currentDrop = null;
                    sI.currentDropStage = step.parentStage;
                }
                
                this.manageVerticalLineLeft(sI);
                //this.manageBorderLeftForLeft(sI);
                sI.currentMoveRight = null; // Resetting
            },

            manageVerticalLineLeft: function(sI) {
                console.log("here .. manageVerticalLineLeft");
                var index = sI.movedStepIndex;
                var place;
                place = (sI.kanvas.allStepViews[index].left - 10);
                
                if(sI.kanvas.allStepViews[index].previousIsMoving === true) {
                    
                    place = sI.kanvas.moveDots.left + 7;
                }        
                
                var step = sI.kanvas.allStepViews[index];
                if(! step.previousStep) {
                    sI.verticalLine.setLeft(place - 8);
                    sI.verticalLine.borderS.setLeft(place - 12);
                } else {
                    sI.verticalLine.setLeft(place - 5);
                    sI.verticalLine.borderS.setLeft(place + 15);
                }
                sI.verticalLine.setCoords();
                sI.verticalLine.borderS.setCoords();
                //si.kanvas.canvas.bringToFront(sI.verticalLine.border);
            },

            manageBorderLeftForLeft: function(sI) {
                
                var index = sI.movedStepIndex;

                if(sI.kanvas.allStepViews[index + 1]) {
                    sI.kanvas.allStepViews[index + 1].borderLeft.setVisible(false);
                }
                sI.kanvas.allStepViews[index].borderLeft.setVisible(true);
            }
        };
    }
]);
