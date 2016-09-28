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

angular.module("canvasApp").service('stepEvents',[
  'stageGraphics',
  'stepGraphics',
  function(stageGraphics, stepGraphics) {

    var that = this;
    this.changeDeltaText = function($scope) {

      var stage = $scope.fabricStep.parentStage;
      if(stage.model.stage_type === "cycling") {
        stage.childSteps.forEach(function(step, index) {
          stepGraphics.autoDeltaDetails.call(step);
        });
      }
    };

    this.init = function($scope, canvas, C) {

      $scope.$watch('step.temperature', function(newVal, oldVal) {

        var circle = $scope.fabricStep.circle;
        circle.circleGroup.top = circle.getTop().top;
        circle.manageDrag(circle.circleGroup);
        circle.circleGroup.setCoords();
        canvas.renderAll();
      });

      $scope.$watch('step.ramp.rate', function(newVal, oldVal) {

        $scope.fabricStep.showHideRamp();
        canvas.renderAll();
      });

      $scope.$watch('step.name', function(newVal, oldVal) {

        var step = $scope.fabricStep;
        if(step.model.name) {
          step.stepName.text = (step.model.name).charAt(0).toUpperCase() + (step.model.name).slice(1).toLowerCase();
        } else {
          step.stepName.text = "Step " + (step.index + 1);
          step.stepNameText =  "Step " + (step.index + 1);
        }

        canvas.renderAll();
      });

      $scope.$watch('step.hold_time', function(newVal, oldVal) {

        var circle = $scope.fabricStep.circle;
        circle.changeHoldTime();
        //Check the last step. See if the last step has zero and put infinity in that case.
        //C.allCircles[C.allCircles.length - 1].doThingsForLast();
        if($scope.fabricStep.index === C.allStepViews[C.allStepViews.length - 1].index) {
          C.allStepViews[C.allStepViews.length - 1].circle.doThingsForLast(newVal, oldVal);
        }

        canvas.renderAll();
      });

      $scope.$watch('step.collect_data', function(newVal, oldVal) {

        // things to happen wen step.collect_data changes;
        var circle = $scope.fabricStep.circle;
        circle.showHideGatherData(newVal);
        circle.parent.gatherDataDuringStep = newVal;
        canvas.renderAll();
      });

      $scope.$watch('step.ramp.collect_data', function(newVal, oldVal) {

        if( $scope.fabricStep.index !== 0 || $scope.fabricStep.parentStage.index !== 0) {
          //if its not the very first step
          var circle = $scope.fabricStep.circle;
          circle.gatherDataDuringRampGroup.setVisible(newVal);
          circle.parent.gatherDataDuringRamp = newVal;
          canvas.renderAll();
        }
      });

      $scope.$watch('step.pause', function(newVal, oldVal) {

        var circle = $scope.fabricStep.circle;
        circle.controlPause(newVal);
        canvas.renderAll();
      });

      $scope.$watch('step.delta_duration_s', function(newVal, oldVal) {
        that.changeDeltaText($scope);
        canvas.renderAll();
      });

      $scope.$watch('step.delta_temperature', function(newVal, oldVal) {
        that.changeDeltaText($scope);
        canvas.renderAll();
      });
    };
  }
]);
