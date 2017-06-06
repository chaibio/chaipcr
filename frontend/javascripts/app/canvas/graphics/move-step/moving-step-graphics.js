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
        this.offset = 41;
        // Make steg looks good just after clicking move-step, steps well spaced , and other stages moved aways making space.
        this.backupStageModel = null;

        this.initiateMoveStepGraphics = function(currentStep, C) {
            console.log("spot", currentStep.parentStage.model);
            this.backupStageModel = angular.copy(currentStep.parentStage.model); 
            console.log("spot", this.backupStageModel);
            this.arrangeStepsOfStage(currentStep, C);
            this.arrangeStages(currentStep.parentStage);
            this.setWidthOfStage(currentStep.parentStage);
            this.setLeftOfStage(currentStep.parentStage);
            this.adjustStep(currentStep);
            this.adjustStage(currentStep.parentStage);
        };

        this.setWidthOfStage = function(baseStage) {
            //baseStage.setNewWidth(-60);
            baseStage.myWidth = baseStage.myWidth - (this.offset * 2);
            baseStage.roof.setWidth(baseStage.myWidth).setCoords();
            baseStage.stageGroup.setLeft(baseStage.stageGroup.left + this.offset).setCoords();
            baseStage.dots.setLeft(baseStage.dots.left + this.offset).setCoords();
        };

        this.setLeftOfStage = function(baseStage) {
            baseStage.left = baseStage.left + this.offset;
        };

        this.arrangeStepsOfStage = function(step, C) {
            
            var startingStep = step.previousStep;
            
            while(startingStep) {
                this.moveLittleRight(startingStep);
                startingStep = startingStep.previousStep;
            }
           // step.parentStage.border.setLeft(step.parentStage.border.left + this.offset).setCoords();
           
        
            //this.squeezeStep(step, C);

            startingStep = step.nextStep;
            while(startingStep) {
                this.moveLittleLeft(startingStep);
                startingStep = startingStep.nextStep;
            }
            
            C.canvas.renderAll();
        };

        this.arrangeStages = function(baseStage) {

            /*var stage = baseStage.previousStage;
            var counter = 1;
             while(stage) {
                stage.left = stage.left - (20 * counter);
                stage.moveStageForMoveStep();
                counter = counter + 1;
                stage = stage.previousStage;
            }

            stage = baseStage.nextStage;
            counter = 1;
            while(stage) {
                stage.left = stage.left + (20 * counter);
                stage.moveStageForMoveStep();
                counter = counter + 1;
                stage = stage.nextStage;
            }*/
        };

        this.squeezeStep = function(step, C) {
            // Should be moved, because this is not about graphics
            step.parentStage.deleteFromStage(step.index, step.ordealStatus);
            if(step.parentStage.childSteps.length === 0) {
                step.parentStage.wireStageNextAndPrevious();
                selected = (step.parentStage.previousStage) ? step.parentStage.previousStage.childSteps[step.parentStage.previousStage.childSteps.length - 1] : step.parentStage.nextStage.childSteps[0];
                step.parentStage.parent.allStageViews.splice(step.parentStage.index, 1);
                selected.parentStage.updateStageData(-1);
                C.canvas.renderAll();
            }    
        };

        this.moveLittleRight = function(step) {
            console.log("Right");
            step.left = step.left + this.offset;
            step.moveStep(0, false);
            step.circle.moveCircleWithStep();
        };

        this.moveLittleLeft = function(step) {
            console.log("Left");
            step.left = step.left - this.offset;
            step.moveStep(0, false);
            step.circle.moveCircleWithStep();
        };

        this.adjustStep = function(step) {
            // reduce the width of the step and adjust
        };

        this.adjustStage = function(stage) {

        };

        this.correctStageAfterDrop = function(baseStage) {
            console.log(baseStage);
            baseStage.myWidth = (baseStage.model.steps.length * (constants.stepWidth)) + constants.additionalWidth;
            baseStage.roof.setWidth(baseStage.myWidth).setCoords();
            //baseStage.getLeft();
            //baseStage.stageGroup.setLeft(baseStage.stageGroup.left + this.offset).setCoords();
            //baseStage.dots.setLeft(baseStage.dots.left + this.offset).setCoords();
            //baseStage.stageGroup.setLeft(baseStage.stageGroup.left + this.offset).setCoords();
            //baseStage.dots.setLeft(baseStage.dots.left + this.offset).setCoords();

        };

        return this;
    }
]);
