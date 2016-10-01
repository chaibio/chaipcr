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

angular.module("canvasApp").directive('actions', [
  'ExperimentLoader',
  '$timeout',
  'canvas',
  'popupStatus',

  function(ExperimentLoader, $timeout, canvas, popupStatus) {
    return {
      restric: 'EA',
      replace: true,
      templateUrl: 'app/views/directives/actions.html',

      link: function(scope, elem, attr) {

        scope.actionPopup = false;
        scope.infiniteHoldStep = false;
        scope.infiniteHoldStage = false;
        scope.editStageMode = false;
        scope.editStageText = "EDIT STAGES";

        scope.$on("dataLoaded", function() {

          scope.$watch("actionPopup", function(newVal) {
            popupStatus.popupStatusAddStage = scope.actionPopup;
          });

          scope.$watch('step.pause', function(pauseState) {

            if(pauseState) {
              scope.pauseAction = "REMOVE";
            } else {
              scope.pauseAction = "ADD A";
            }
          });

          scope.$watch("step.id", function(newVal) {

            if(scope.fabricStep) {

              if(scope.fabricStep.circle.holdTime.text === "∞") {
                scope.infiniteHoldStep = scope.infiniteHoldStage = true;
                return true;
              }
              scope.infiniteHoldStep = false;

              if(scope.containInfiniteStep(scope.fabricStep.parentStage)) {
                scope.infiniteHoldStage = true;
                return true;
              }

              scope.infiniteHoldStage = false;
            }
          });
        });

        scope.addStage_ = function() {

          if(!scope.summaryMode) {
            scope.actionPopup = ! scope.actionPopup;
          }
        };

        scope.containInfiniteStep = function(stage) {

          var lastStep = stage.childSteps[stage.childSteps.length - 1];
          if(lastStep.circle.holdTime.text === "∞") {
            return true;
          }
          return false;
        };

        scope.addStep = function() {

          if(! scope.infiniteHoldStep && ! scope.summaryMode) {
            ExperimentLoader.addStep(scope)
              .then(function(data) {
                //Now create a new step and insert it...!
                scope.fabricStep.parentStage.addNewStep(data, scope.fabricStep);
              });
          }
        };

        scope.deleteStep = function() {

          ExperimentLoader.deleteStep(scope)
            .then(function(data) {
              console.log("deleted", data);
              scope.fabricStep.parentStage.deleteStep(data, scope.fabricStep);
            });
        };

        scope.editStage = function() {
          if(! scope.summaryMode) {
            scope.editStageMode = ! scope.editStageMode;
            scope.editStageText = (scope.editStageMode) ? "DONE" : "EDIT STAGES";
            canvas.editStageMode(scope.editStageMode);
          }
        };

        scope.addPause = function() {

          if(! scope.infiniteHoldStep && ! scope.summaryMode) {
            scope.step.pause = ! scope.step.pause;
            ExperimentLoader.changePause(scope)
            .then(function(data) {
              console.log("added", data);
            });
          }
        };

      }
    };
  }
]);
