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

angular.module("canvasApp").factory('stage', [
  'ExperimentLoader',
  '$rootScope',
  'step',
  'previouslySelected',
  'stageGraphics',
  'stepGraphics',
  'constants',
  'circleManager',

  function(ExperimentLoader, $rootScope, step, previouslySelected, stageGraphics, stepGraphics, constants, circleManager) {

    return function(model, stage, allSteps, index, fabricStage, $scope, insert) {

      this.model = model;
      this.index = index;
      this.canvas = stage;
      this.myWidth = (this.model.steps.length * (constants.stepWidth)) + constants.additionalWidth;
      this.parent = fabricStage;
      this.childSteps = [];
      this.previousStage = this.nextStage = this.noOfCycles = null;
      this.insertMode = insert;
      this.shrinked = false;
      this.shadowText = "0px 1px 2px rgba(0, 0, 0, 0.5)";
      this.visualComponents = {};
      this.stageMovedDirection = null;
      this.shortStageName = false;
      this.shrinkedStage = false;

      this.setNewWidth = function(add) {

        this.myWidth = this.myWidth + add;
        this.stageRect.setWidth(this.myWidth);
        this.stageRect.setCoords();
        this.roof.setWidth(this.myWidth);
      };

      this.shrinkStage = function() {


        this.shrinked = true;
        this.myWidth = this.myWidth - 64;
        this.stageHitPointLowerRight.setLeft(this.stageHitPointLowerRight.left - 64).setCoords();
        this.roof.setWidth(this.myWidth).setCoords();
        this.stageRect.setWidth(this.myWidth).setCoords();
        // this.stageHitPointLowerRight.set({left: this.stageHitPointLowerRight.left - 64}).setCoords();
        // Befor actually move the step in process movement stage values.
        // Find next stageDots
        // Move all the steps in it to left.
        // Move stage to left ...!!
      };

      this.collapseStage = function() {
        // Remove all content in the stage first
        console.log("okay Shrinking");
        this.childSteps.forEach(function(step, index) {
          this.deleteAllStepContents(step);
        }, this);

        this.deleteStageContents();
        // Bring other stages closer
        if(this.nextStage) {
          var width = this.myWidth;
          // This is a trick, when we moveAllStepsAndStages we calculate the placing with myWidth, please refer getLeft() method
          this.myWidth = 23;
          this.moveAllStepsAndStages(true);
          this.myWidth = width;
        }
      };

      this.expand = function() {
        this.myWidth = this.myWidth + 64;
      };

      this.addNewStep = function(data, currentStep) {

        this.setNewWidth(constants.stepWidth);
        this.moveAllStepsAndStages();
        // Now insert new step;
        var start = currentStep.index;
        var newStep = new step(data.step, this, start, $scope);
        newStep.name = "I am created";
        newStep.render();
        newStep.ordealStatus = currentStep.ordealStatus;

        this.childSteps.splice(start + 1, 0, newStep);
        this.model.steps.splice(start + 1, 0, data);
        this.configureStep(newStep, start);
        this.parent.allStepViews.splice(currentStep.ordealStatus, 0, newStep);

        this.parent.correctNumbering();
        newStep.circle.moveCircle();
        newStep.circle.getCircle();

        circleManager.addRampLines();
        //circleManager.init(fabricStage);
        //circleManager.addRampLinesAndCircles(circleManager.reDrawCircles());
        this.stageHeader();
        $scope.applyValues(newStep.circle);
        newStep.circle.manageClick(true);
        stageGraphics.recalculateStageHitPoint.call(this);
        this.parent.setDefaultWidthHeight();
      };

      this.deleteStep = function(data, currentStep) {
        // This methode says what happens in the canvas when a step is deleted
        var selected;
        this.setNewWidth(constants.stepWidth * -1);
        this.deleteAllStepContents(currentStep);
        selected = this.wireNextAndPreviousStep(currentStep, selected);

        var start = currentStep.index;
        var ordealStatus = currentStep.ordealStatus;
        // Delete data from arrays
        this.childSteps.splice(start, 1);
        this.model.steps.splice(start, 1);
        this.parent.allStepViews.splice(ordealStatus - 1, 1);
        //this.parent.correctNumbering();
        if(this.childSteps.length > 0) {
          this.configureStepForDelete(currentStep, start);
        } else { // if all the steps in the stages are deleted, We delete the stage itself.
          this.deleteStageContents();
          this.wireStageNextAndPrevious();

          selected = (this.previousStage) ? this.previousStage.childSteps[this.previousStage.childSteps.length - 1] : this.nextStage.childSteps[0];
          this.parent.allStageViews.splice(this.index, 1);
          selected.parentStage.updateStageData(-1);
        }
        // true imply call is from delete section;
        this.moveAllStepsAndStages(true);

        this.parent.correctNumbering();
        //circleManager.addRampLines();
        circleManager.init(fabricStage);
        circleManager.addRampLinesAndCircles(circleManager.reDrawCircles());
        this.stageHeader();
        $scope.applyValues(selected.circle);
        selected.circle.manageClick();
        stageGraphics.recalculateStageHitPoint.call(this);

        if(this.parent.allStepViews.length === 1) {
          this.parent.editStageMode(this.parent.editStageStatus);
        }

        this.parent.setDefaultWidthHeight();
      };

      this.wireStageNextAndPrevious = function() {

        if(this.previousStage) {
          this.previousStage.nextStage = (this.nextStage) ? this.nextStage : null;
        } else {
          this.nextStage.previousStage = null;
        }

        if(this.nextStage) {
          this.nextStage.previousStage = (this.previousStage) ? this.previousStage : null;
        } else {
          this.previousStage.nextStage = null;
        }
      };

      this.wireNextAndPreviousStep = function(currentStep, selected) {

        if(currentStep.previousStep) {
          currentStep.previousStep.nextStep = (currentStep.nextStep) ? currentStep.nextStep : null;
          selected = currentStep.previousStep;
        }

        if(currentStep.nextStep) {
          currentStep.nextStep.previousStep = (currentStep.previousStep) ? currentStep.previousStep: null;
          selected = currentStep.nextStep;
        }
        return selected;
      };

      this.deleteStageContents = function() {

        this.stageHitPointLeft.setVisible(false);
        this.stageHitPointRight.setVisible(false);

        for(var component in this.visualComponents) {
          if(component === "dots") {
            var items = this.dots._objects;
            this.canvas.remove(this.dots);
            this.dots.forEachObject(function(O) {
              this.canvas.remove(O);
              this.dots.removeWithUpdate(O);
            }, this);
            this.canvas.discardActiveGroup();
            continue;
          }
          this.canvas.remove(this.visualComponents[component]);
        }
      };

      this.deleteAllStepContents = function(currentStep) {

        for(var component in currentStep.visualComponents) {
          this.canvas.remove(currentStep.visualComponents[component]);
        }
        currentStep.circle.removeContents();
      };

      this.moveIndividualStageAndContents = function(stage, del) {
        if(!stage.nextStage) {
          return false;
        }
        stage.nextStage.getLeft();
        stage.nextStage.stageGroup.set({left: stage.nextStage.left }).setCoords();
        stage.nextStage.dots.set({left: stage.nextStage.left + 3}).setCoords();
        stage.nextStage.stageHitPointLeft.set({left: stage.nextStage.left + 10}).setCoords();
        stage.nextStage.stageHitPointRight.set({left: (stage.nextStage.left + stage.nextStage.myWidth) -  20}).setCoords();
        stage.nextStage.stageHitPointLowerLeft.set({left: stage.nextStage.left + 10}).setCoords();
        stage.nextStage.stageHitPointLowerRight.set({left: (stage.nextStage.left + stage.nextStage.myWidth) -  20}).setCoords();

        //stage.nextStage.moveStageRightPointerDetector.set({left: (stage.nextStage.left + stage.nextStage.myWidth) +  50}).setCoords();

        stage.nextStage.childSteps.forEach(function(childStep, index) {

          if (del === true) {
            childStep.moveStep(-1, true);
          } else {
            childStep.moveStep(1, true);
          }
          childStep.circle.moveCircleWithStep();
        });

      };

      this.moveIndividualStageAndContentsSpecial = function(stage, del) {

        stage.getLeft();

        stage.stageGroup.set({left: stage.left }).setCoords();
        stage.dots.set({left: stage.left + 3}).setCoords();
        stage.stageHitPointLeft.set({left: stage.left + 10}).setCoords();
        stage.stageHitPointRight.set({left: (stage.left + stage.myWidth) -  20}).setCoords();
        stage.stageHitPointLowerLeft.set({left: stage.left + 10}).setCoords();
        stage.stageHitPointLowerRight.set({left: (stage.left + stage.myWidth) -  20}).setCoords();

        //stage.moveStageRightPointerDetector.set({left: (stage.left + stage.myWidth) +  50}).setCoords();

        stage.childSteps.forEach(function(childStep, index) {

          if (del === true) {
            childStep.moveStep(-1, true);
          } else {
            childStep.moveStep(1, true);
          }
          childStep.circle.moveCircleWithStep();
        });

      };

      //
      this.makeSurePreviousMovedLeft = function(draggedStage) {
        var stage = this.previousStage;
        while(stage) {
          if(stage.stageMovedDirection !== "left") {
            console.log("Looking");
            stage.moveToSide("left", null, null, draggedStage);
          }
          stage = stage.previousStage;
        }
      };
      //
      this.makeSureNextMovedRight = function(draggedStage) {
        var stage = this.nextStage;
        while(stage) {
          if(stage.stageMovedDirection !== "right") {
            stage.moveToSide("right", null, null, draggedStage);
          }
          stage = stage.nextStage;
        }
      };

      //This method is used when move stage hits at the hitPoint at the side of the stage.
      this.moveToSide = function(direction, spaceArrayRight, spaceArrayLeft, draggedStage) {

        if(this.validMove(direction, draggedStage)) {

          var moveCount;
          if(direction === "left") {
            moveCount = -30;
            this.makeSurePreviousMovedLeft(draggedStage);
          } else if("right") {
            moveCount = 30;
            this.makeSureNextMovedRight(draggedStage);
          }

          if(spaceArrayRight && spaceArrayLeft) {
            if(direction === "right") {
              spaceArrayLeft[0] = this.left - 82;
              spaceArrayLeft[1] = this.left - 44;

              spaceArrayRight[0] = this.left + 60;
              spaceArrayRight[1] = this.left + 98;
            } else if (direction === "left") {
              spaceArrayRight[0] = (this.left + this.myWidth) + 40;
              spaceArrayRight[1] = (this.left + this.myWidth) + 78;

              spaceArrayLeft[0] = (spaceArrayRight[1] - 186);
              spaceArrayLeft[1] = spaceArrayRight[0] - 104;
            }
          }

          this.moveToSideStageComponents(moveCount);

          this.stageMovedDirection = direction; // !important
          return "Valid Move";
        }
        return null;
      };

      this.moveToSideStageComponents = function(moveCount) {

        this.stageGroup.set({left: this.left + moveCount }).setCoords();
        this.dots.set({left: (this.left + moveCount ) + 3}).setCoords();
        this.stageHitPointLeft.set({left: (this.left + moveCount ) + 10}).setCoords();
        this.stageHitPointRight.set({left: ((this.left + moveCount ) + this.myWidth) -  20}).setCoords();
        this.stageHitPointLowerLeft.set({left: (this.left + moveCount ) + 10}).setCoords();
        this.stageHitPointLowerRight.set({left: ((this.left + moveCount ) + this.myWidth) -  20}).setCoords();
        this.left = this.left + moveCount;

        this.childSteps.forEach(function(step, index) {
          step.moveStep(1, true);
          step.circle.moveCircleWithStep();
        });
      };

      this.validMove = function(direction, draggedStage) {

        if(this.stageMovedDirection === null) {

          if(direction === "left") {
            // For very first stage, It can't move further left.
            if(this.previousStage === null) {
              //return false;
              if(draggedStage.index !== 0) {
                return false;
              }
            }
            // look if we have space at left;
            if(this.previousStage && this.left - (this.previousStage.left + this.previousStage.myWidth) < 10) {
              return false;
            }
            this.stageMovedDirection = "left";

          } else if(direction === "right") {

            if(this.nextStage === null) {

              if(draggedStage.index === this.parent.allStageViews.length) {
                // For the very first time, we need to move only if we dragged the very last stage.
                this.stageMovedDirection = "right";
                return true;
              }
              return false;
            }
            // We move only if we have space in the right side.
            if(this.nextStage && (this.nextStage.left) - (this.left + this.myWidth) < 10) {
              return false;
            }
            this.stageMovedDirection = "right";
          }
        } else if(this.stageMovedDirection){ // if it has left or right value
          if(this.stageMovedDirection === "left" && direction === "left") {
            return false;
          }
          if(this.stageMovedDirection === "right" && direction === "right") {
            return false;
          }
        }

        return true;
      };

      this.moveAllStepsAndStages = function(del) {

        var currentStage = this;

        while(currentStage) {

          this.moveIndividualStageAndContents(currentStage, del);

          currentStage = currentStage.nextStage;
        }
      };

      this.moveAllStepsAndStagesSpecial = function(del) {

        var currentStage = this;

        while(currentStage) {

          this.moveIndividualStageAndContentsSpecial(currentStage, del);

          currentStage = currentStage.nextStage;
        }
      };
      this.updateStageData = function(action) {

          if(! this.previousStage && action === -1 && this.index === 1) {
            // This is a special case when very first stage is being deleted and the second stage is selected right away..!
            this.index = this.index + action;
            this.stageHeader();
          }
          var currentStage = this.nextStage;

          while(currentStage) {
            currentStage.index = currentStage.index + action;
            currentStage.stageHeader();
            currentStage = currentStage.nextStage;
          }

      };

      this.configureStepForDelete = function(newStep, start) {

        this.childSteps.slice(0, start).forEach(function(thisStep) {
          thisStep.configureStepName();
        }, this);

        this.childSteps.slice(start, this.childSteps.length).forEach(function(thisStep) {

          thisStep.index = thisStep.index - 1;
          thisStep.configureStepName();
          thisStep.moveStep(-1, true);
        }, this);
      };

      this.configureStep = function(newStep, start) {
        // insert it to all steps, add next and previous , re-render circles;
        for(var j = 0; j < this.childSteps.length; j++) {

          var thisStep = this.childSteps[j];
          if(j >= start + 1) {
            thisStep.index = thisStep.index + 1;
            thisStep.configureStepName();
            thisStep.moveStep(1, true);
          } else {
            thisStep.numberingValue();
          }
        }

        if(this.childSteps[newStep.index + 1]) {
          newStep.nextStep = this.childSteps[newStep.index + 1];
          newStep.nextStep.previousStep = newStep;
        }

        if(this.childSteps[newStep.index - 1]) {
          newStep.previousStep = this.childSteps[newStep.index - 1];
          newStep.previousStep.nextStep = newStep;
        }
      };

      this.shortenStageName = function() {
        var text = this.stageName.text.substr(0, 8);
        this.stageName.setText(text);
        this.shortStageName = true;
      };

      this.getLeft = function() {

        if(this.previousStage) {
          this.left = this.previousStage.left + this.previousStage.myWidth + constants.newStageOffset;
        } else {
          this.left = 33;
        }
        return this;
      };

      this.addSteps = function() {

        var stepView, that = this;
        this.childSteps = [];

        // We use reduce here so that Linking is easy here, because reduce retain the previous value which we return.
        this.model.steps.reduce(function(tempStep, STEP, stepIndex) {

          stepView = new step(STEP.step, that, stepIndex, $scope);

          if(tempStep) {
            tempStep.nextStep = stepView;
            stepView.previousStep = tempStep;
          }

          that.childSteps.push(stepView);

          if(! that.insertMode) {
            allSteps.push(stepView);
            stepView.ordealStatus = allSteps.length;
            stepView.render();
          }

          return stepView;
        }, null);
      };

      this.stageHeader = function() {
        if(this.stageName) {
          var index = parseInt(this.index) + 1;
          var stageName = (this.model.name).toUpperCase().replace("STAGE", "");
          var text = (stageName).trim();
          this.stageCaption.setText("STAGE " + index + ": " );

          if(this.model.stage_type === "cycling") {
            var noOfCycles = this.model.num_cycles;
            noOfCycles = String(noOfCycles);
            text = text + ", " + noOfCycles + "x";
          }

          this.stageName.setText(text);
          this.stageName.setLeft(this.stageCaption.left + this.stageCaption.width);

          if(this.parent.editStageStatus && this.childSteps.length === 1) {
            this.shortenStageName();
          } else {
            this.shortStageName = false;
          }
        }
      };

      this.render = function() {

          this.getLeft();
          stageGraphics.addRoof.call(this);
          stageGraphics.borderLeft.call(this);
          stageGraphics.writeMyName.call(this);
          stageGraphics.createStageRect.call(this);
          stageGraphics.dotsOnStage.call(this);
          this.stageHeader();
          stageGraphics.createStageHitPoints.call(this);

          var stageContents = [this.stageRect, this.stageNameGroup, this.roof, this.border]; //this.dots
          stageGraphics.createStageGroup.apply(this, [stageContents]);

          this.visualComponents = {
            'stageGroup': this.stageGroup,
            'dots': this.dots,
            'stageHitPointLeft': this.stageHitPointLeft,
            'stageHitPointRight': this.stageHitPointRight,
            'stageHitPointLowerLeft': this.stageHitPointLowerLeft,
            'stageHitPointLowerRight': this.stageHitPointLowerRight,
            //'moveStageRightPointerDetector' : this.moveStageRightPointerDetector,
            'borderRight': this.borderRight
          };

          this.canvas.add(this.stageGroup);
          this.canvas.add(this.dots);
          this.canvas.add(this.stageHitPointLeft);
          this.canvas.add(this.stageHitPointRight);
          this.canvas.add(this.stageHitPointLowerLeft);
          this.canvas.add(this.stageHitPointLowerRight);
          //this.canvas.add(this.moveStageRightPointerDetector);

          this.setShadows();

          this.addSteps();
          stageGraphics.recalculateStageHitPoint.call(this);
      };

      this.setShadows = function() {

        this.stageName.setShadow(this.shadowText);
        this.stageCaption.setShadow(this.shadowText);
      };

      this.manageBordersOnSelection = function(color) {

        if(this.childSteps[this.childSteps.length - 1]) {
          this.border.setStroke(color);
          this.childSteps[this.childSteps.length - 1].borderRight.setStroke(color);
          this.childSteps[this.childSteps.length - 1].borderRight.setStrokeWidth(2);
        }
      };

      this.changeFillsAndStrokes = function(color, strokeWidth)  {

        this.roof.setStroke(color);
        this.roof.setStrokeWidth(strokeWidth);

        if(this.parent.editStageStatus) {
          this.dots.forEachObject(function(obj) {
            if(obj.name === "stageDot") {
              obj.setFill(color);
            }
          });
          this.canvas.bringToFront(this.dots);
          this.dots.setCoords();
        }

        this.stageName.setFill(color);
        this.stageCaption.setFill(color);
      };

      this.selectStage =  function() {

        if(previouslySelected.circle) {
          this.unSelectStage();
        }

        this.changeFillsAndStrokes("black", 4);
        this.manageBordersOnSelection("#cc6c00");
      };

      this.removeFromStagesArray = function() {


        this.parent.allStageViews.splice(this.index, 1);

        var length = this.parent.allStageViews.length;

        for( i = this.index;  i < length; i++) {
          this.parent.allStageViews[i].index = i;
        }
        console.log(this.index, this.parent.allStageViews);
        //debugger;
      };

      this.unSelectStage = function() {

        var previousSelectedStage = previouslySelected.circle.parent.parentStage;

        previousSelectedStage.changeFillsAndStrokes("white", 2);
        previousSelectedStage.manageBordersOnSelection("#ff9f00");
      };
    };

  }
]);
