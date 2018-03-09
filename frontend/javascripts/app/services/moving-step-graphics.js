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
    'Line',
    'constants',
    function(Line, constants) {
        this.offset = 0;
        
        this.initiateMoveStepGraphics = function(currentStep, C) {
            
            this.arrangeStepsOfStage(currentStep);
            this.setWidthOfStage(currentStep.parentStage);
            this.setLeftOfStage(currentStep.parentStage);
        };

        this.setWidthOfStage = function(baseStage) {
            
            //this.offset = 10;
            baseStage.myWidth = baseStage.myWidth - 60;
            
            baseStage.stageRect.setWidth(baseStage.myWidth);
            baseStage.stageRect.setCoords();
            
            baseStage.roof.setWidth(baseStage.myWidth);
            baseStage.roof.setCoords();
            
            baseStage.stageGroup.setLeft(baseStage.stageGroup.left + this.offset);
            baseStage.stageGroup.setCoords();

            baseStage.dots.setLeft(baseStage.dots.left + this.offset);
            baseStage.dots.setCoords();
        };

        this.setLeftOfStage = function(baseStage) {
            baseStage.left = baseStage.left + this.offset;
        };

        this.arrangeStepsOfStage = function(step) {
            
            //var startingStep = step.previousStep;
            
            //while(startingStep) {
                //this.moveLittleRight(startingStep); // may be remove this part and method.
                //startingStep = startingStep.previousStep;
            //}
           
            var startingStep = step.nextStep;
            while(startingStep) {
                this.moveLittleLeft(startingStep);
                startingStep = startingStep.nextStep;
            }
        };

        this.moveLittleRight = function(step) {
            
            step.left = step.left + this.offset;
            step.moveStep(0, false);
            step.circle.moveCircleWithStep();
        };

        this.moveLittleLeft = function(step) {
            
            step.left = step.left - 82;
            step.moveStep(0, false);
            step.circle.moveCircleWithStep();
        };

        return this;
    }
]);
