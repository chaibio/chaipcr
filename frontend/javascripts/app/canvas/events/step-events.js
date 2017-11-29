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
  'TimeService',
  'pauseStepService',
  'moveRampLineService',
  function(stageGraphics, stepGraphics, TimeService, pauseStepService, moveRampLineService) {

    var that = this;
    var _$scope, _canvas, _C;

    

    this.init = function($scope, canvas, C) {

      _$scope = $scope;
      _canvas = canvas;
      _C = C;
      
      $scope.$watch('step.temperature', that.manageTemperatureChange);

      $scope.$watch('step.ramp.rate', that.manageRampRateChange);

      $scope.$watch('step.name', that.manageStepNameChange);

      $scope.$watch('step.hold_time', that.manageStepHoldTimeChange);

      $scope.$watch('step.collect_data', that.manageStepCollectDataChange);

      $scope.$watch('step.ramp.collect_data', that.manageStepRampCollectData);

      $scope.$watch('step.pause', that.manageStepPause);

      $scope.$watch('step.delta_duration_s', that.manageStepDeltaDurationS);

      $scope.$watch('step.delta_temperature', that.manageStepDeltaTemperature);
    };

    this.manageTemperatureChange = function(newVal, oldVal) {
        
        var circle = _$scope.fabricStep.circle;
        circle.circleGroup.top = circle.getTop().top;
        moveRampLineService.manageDrag(circle.circleGroup);
        circle.circleGroup.setCoords();
        _canvas.renderAll();
    };

    this.manageRampRateChange = function(newVal, oldVal) {

      _$scope.fabricStep.showHideRamp();
      _canvas.renderAll();
    };

    this.manageStepNameChange = function(newVal, oldVal) {

        var step = _$scope.fabricStep;

        if(step.model.name) {
          step.stepName.text = (step.model.name).charAt(0).toUpperCase() + (step.model.name).slice(1).toLowerCase();
        } else {
          step.stepName.text = "Step " + (step.index + 1);
          step.stepNameText =  "Step " + (step.index + 1);
        }

        _canvas.renderAll();
    };

    this.manageStepHoldTimeChange = function(newVal, oldVal) {

        var circle = _$scope.fabricStep.circle;

        var val = TimeService.newTimeFormatting(newVal);
        circle.changeHoldTime(val);
        //Check the last step. See if the last step has zero and put infinity in that case.
        //C.allCircles[C.allCircles.length - 1].doThingsForLast();
        if(_$scope.fabricStep.index === _C.allStepViews[_C.allStepViews.length - 1].index) {
          _C.allStepViews[_C.allStepViews.length - 1].circle.doThingsForLast(newVal, oldVal);
        }

        _canvas.renderAll();
    };

    this.manageStepCollectDataChange = function(newVal, oldVal) {

      // things to happen wen step.collect_data changes;
        var circle = _$scope.fabricStep.circle;
        circle.showHideGatherData(newVal);
        circle.parent.gatherDataDuringStep = newVal;
        _canvas.renderAll();
    };

    this.manageStepRampCollectData = function(newVal, oldVal) {

        if(_$scope.fabricStep.index !== 0 || _$scope.fabricStep.parentStage.index !== 0) {
          //if its not the very first step
          var circle = _$scope.fabricStep.circle;
          circle.gatherDataDuringRampGroup.setVisible(newVal);
          circle.parent.gatherDataDuringRamp = newVal;
          _canvas.renderAll();
        }
    };

    this.manageStepPause = function(newVal, oldVal) {

      var circle = _$scope.fabricStep.circle;
      pauseStepService.controlPause(circle);
      _canvas.renderAll();
    };

    that.manageStepDeltaDurationS = function(newVal, oldVal) {
      
      that.changeDeltaText(_$scope);
      _canvas.renderAll();
    };

    that.manageStepDeltaTemperature = function(newVal, oldVal) {

      that.changeDeltaText(_$scope);
      _canvas.renderAll();
    };

    this.changeDeltaText = function($scope) {

      var stage = _$scope.fabricStep.parentStage;
      if(stage.model.stage_type === "cycling") {
        stage.childSteps.forEach(function(step, index) {
          stepGraphics.autoDeltaDetails.call(step);
        });
      }
    };

  }
]);
