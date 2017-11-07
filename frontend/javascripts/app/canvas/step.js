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

angular.module("canvasApp").factory('step', [
  'circle',
  'previouslySelected',
  'stepGraphics',
  'constants',

  function(circle, previouslySelected, stepGraphics, constants) {

    return function(model, parentStage, index, $scope) {

      this.stepMovedDirection = null;
      this.model = model;
      this.parentStage = parentStage;
      this.index = index;
      this.canvas = parentStage.canvas;
      this.myWidth = constants.stepWidth;
      this.$scope = $scope;
      this.nextIsMoving = null;
      this.previousIsMoving = null;
      this.nextStep = null;
      this.previousStep = null;
      this.gatherDataDuringStep = this.model.collect_data;
      this.gatherDataDuringRamp = this.model.ramp.collect_data;
      this.shrinked = false;
      this.shadowText = "0px 1px 2px rgba(0, 0, 0, 0.5)";
      this.visualComponents = {};

      this.setLeft = function() {

        this.left = this.parentStage.left + 3 + (parseInt(this.index) * this.myWidth);
        return this;
      };

      this.toggleComponents = function(state) {

        this.circle.stepDataGroup.setVisible(state);
        this.circle.gatherDataOnScroll.setVisible(state);
        this.circle.circleGroup.setVisible(state);
        this.circle.gatherDataDuringRampGroup.setVisible(state);
        this.closeImage.setVisible(state);
        this.stepName.setVisible(state);
        this.numberingTextCurrent.setVisible(state);
        this.numberingTextTotal.setVisible(state);
      };

      this.moveStep = function(action, callSetLeft) {

        if(callSetLeft) {
          this.setLeft();
        }

        this.getUniqueName();

        var leftVal = {left: this.left};

        this.stepGroup.set(leftVal);
        this.stepGroup.setCoords();

        leftVal = {left: this.left + (this.myWidth / 2)};

        leftVal = {left: this.left + 108};

        this.closeImage.set(leftVal);
        this.closeImage.setCoords();

        leftVal = {left: this.left + 16};

        this.dots.set(leftVal);
        this.dots.setCoords();

        leftVal = {left: this.left + 5};
        
        this.rampSpeedGroup.set(leftVal);
        this.rampSpeedGroup.setCoords();

        this.ordealStatus = this.ordealStatus + action;
        this.circle.getUniqueId();

      };

      this.deleteAllStepContents = function() {

        for(var component in this.visualComponents) {
          this.canvas.remove(this.visualComponents[component]);
        }
        this.circle.removeContents();
      };

      this.wireNextAndPreviousStep = function(currentStep, selected) {
        
        if(this.previousStep) {
          this.previousStep.nextStep = (this.nextStep) ? this.nextStep : null;
          selected = this.previousStep;
        }

        if(this.nextStep) {
          this.nextStep.previousStep = (this.previousStep) ? this.previousStep: null;
          selected = this.nextStep;
        }
        return selected;
      };

      this.configureStepName = function() {

        if(this.model.name === null) {
          this.stepNameText = "Step " + (this.index + 1);
          this.stepName.text = this.stepNameText;
        } else {
          this.stepName.text = this.model.name;
        }
        this.numberingValue();
      };

      this.addCircle = function() {

        this.circle = new circle(this.model, this, $scope);
        this.circle.getLeft();
        this.circle.getTop();
        this.circle.getUniqueId();
        this.circle.addImages();
        this.circle.render();
      };

      this.getUniqueName = function() {

        this.uniqueName = this.model.id + this.parentStage.index + "step";
        return this;
      };

      this.showHideRamp = function() {

        this.rampSpeedText.text = String(this.model.ramp.rate + "º C/s");
        var rampRate = Number(this.model.ramp.rate);
        if(!rampRate || rampRate >= 5 || rampRate <=0) {
          this.rampSpeedGroup.setVisible(false);
        } else {
          this.rampSpeedGroup.setVisible(true);
          this.underLine.setWidth(this.rampSpeedText.width);
        }

        this.canvas.renderAll();
      };

      this.adjustRampSpeedPlacing = function() {

        this.rampSpeedGroup.setTop(this.circle.top + 20);
        return this;
      };

      this.adjustRampSpeedLeft = function() {

        this.circle.runAlongCircle();
        return this;
      };


      this.manageBorder = function(color) {

        this.borderRight.setStroke(color);
        this.borderRight.setStrokeWidth(2);
        if(this.previousStep) {
          this.previousStep.borderRight.setStroke(color);
          this.previousStep.borderRight.setStrokeWidth(2);
        } else {
          this.parentStage.border.setStroke(color);
        }
      };

      this.manageBorderPrevious = function(color, currentStep) {

        if(this.parentStage.childSteps.length - 1 === this.index && this.parentStage.index === currentStep.parentStage.index) {

          this.borderRight.setStroke("#cc6c00");
          this.borderRight.setStrokeWidth(2);
        } else {
          this.borderRight.setStroke(color);
          this.borderRight.setStrokeWidth(1);
        }

        if(this.previousStep) {
          this.previousStep.borderRight.setStroke(color);
          this.previousStep.borderRight.setStrokeWidth(1);
        }
      };

      this.addName = function() {

        var stepName = "Step " + (this.index + 1);
        if(this.model.name) {
          stepName = (this.model.name).charAt(0).toUpperCase() + (this.model.name).slice(1).toLowerCase();
        }

        this.stepNameText = stepName;
        stepGraphics.addName.call(this);
      };

      this.numberingValue = function() {

        var thisIndex = (this.index < 9) ? "0" + (this.index + 1) : (this.index + 1).toString(),
        noofSteps = this.parentStage.model.steps.length;
        thisLength = (noofSteps < 10) ? "0" + noofSteps : noofSteps.toString();
        text = thisIndex + "/" + thisLength;

        this.numberingTextCurrent.setText(thisIndex);
        this.numberingTextTotal.setText("/" + thisLength);
        this.numberingTextTotal.setLeft(this.numberingTextCurrent.left + this.numberingTextCurrent.width);
        return this;
      };

      this.rampSpeedGraphics = function() {
        stepGraphics.rampSpeed.call(this);
        if(this.rampSpeedNumber >= 5) {
          this.rampSpeedGroup.setVisible(false);
        }
      };

      this.swapMoveStepStatus = function(status) {

        this.dots.setVisible(status);
      };

      this.render = function() {

        this.setLeft();
        this.addName();
        stepGraphics.addBorderRight.call(this);
        stepGraphics.addBorderLeft.call(this);
        this.getUniqueName();
        this.rampSpeedGraphics();
        stepGraphics.initNumberText.call(this);
        stepGraphics.initAutoDelta.call(this);
        stepGraphics.autoDeltaDetails.call(this);
        this.numberingValue();
        stepGraphics.deleteButton.call(this);
        stepGraphics.stepFooter.call(this);
        stepGraphics.stepComponents.call(this);

        // Add all those components created.
        this.visualComponents = {
          'stepGroup': this.stepGroup,
          'rampSpeedGroup': this.rampSpeedGroup,
          'closeImage': this.closeImage,
          'dots': this.dots
        };

        this.canvas.add(this.stepGroup);
        this.canvas.add(this.rampSpeedGroup);
        this.canvas.add(this.closeImage);
        this.canvas.add(this.dots);

        this.setShadows();
        this.addCircle();
      };

      this.setShadows = function() {

        this.stepName.setShadow(this.shadowText);
        this.deltaSymbol.setShadow(this.shadowText);
        this.autoDeltaTempTime.setShadow(this.shadowText);
        this.autoDeltaStartCycle.setShadow(this.shadowText);
        this.numberingTextCurrent.setShadow(this.shadowText);
        this.numberingTextTotal.setShadow(this.shadowText);
      };

      this.manageFooter = function(color) {

        this.dots.forEachObject(function(obj) {
        if(obj.name !== "backgroundRect") {
          obj.setFill(color);
        }

        });
      };

      this.selectStep = function() {

        if(previouslySelected.circle) {
          this.unSelectStep();
        }

        this.manageBorder("black");
        if(this.parentStage.parent.editStageStatus) {
          this.manageFooter("black");
        }

        this.stepName.setFill("black");
        this.numberingTextCurrent.setFill("black");
        this.numberingTextTotal.setFill("black");
      };

      this.unSelectStep = function() {
        
        var previouslySelectedStep = previouslySelected.circle.parent;

        if(this.parentStage.parent.editStageStatus) {
          previouslySelectedStep.manageFooter("white");
        }

        previouslySelectedStep.manageBorderPrevious('#ff9f00', this);
        previouslySelectedStep.stepName.setFill("white");
        previouslySelectedStep.numberingTextCurrent.setFill("white");
        previouslySelectedStep.numberingTextTotal.setFill("white");
      };
    };
  }
]);
