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

angular.module("canvasApp").service('movingStepGraphics', [
    function() {
        
        this.initiateMoveStepGraphics = function(currentStep, C) {
            
            this.arrangeStepsOfStage(currentStep, C);
            this.adjustStep(currentStep);
            this.adjustStage(currentStep.parentStage);
        };

        this.arrangeStepsOfStage = function(step, C) {
            
            var startingStep = step.previousStep;
            
            while(startingStep) {
                this.moveLittleRight(startingStep);
                startingStep = startingStep.previousStep;
            }

            startingStep = step.nextStep;

            while(startingStep) {
                this.moveLittleLeft(startingStep);
                startingStep = startingStep.nextStep;
            }

            //step.stepRect.setWidth(45).setCoords();
            step.borderRight.setLeft(-10).setCoords();

            C.canvas.renderAll();
        };

        this.moveLittleRight = function(step) {
            console.log("Right");
            step.left = step.left + 10;
            step.moveStep(0, false);
            step.circle.moveCircleWithStep();
        };

        this.moveLittleLeft = function(step) {
            console.log("Left");
            step.left = step.left - 10;
            step.moveStep(0, false);
            step.circle.moveCircleWithStep();
        };

        this.adjustStep = function(step) {
            // reduce the width of the step and adjust
        };

        this.adjustStage = function(stage) {

        };

        return this;
    }
]);
