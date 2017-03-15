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

window.ChaiBioTech.ngApp.directive('general', [
  'ExperimentLoader',
  '$timeout',
  '$uibModal',
  'alerts',
  'popupStatus',
  '$rootScope',

  function (ExperimentLoader, $timeout, $uibModal, alerts, popupStatus, $rootScope) {

    return {
      restric: 'EA',
      replace: false,
      scope: false,
      templateUrl: 'app/views/directives/general-info.html',

      link: function(scope, elem, attr) {
        console.log("ola");

        scope.stepNameShow = false;
        scope.stageNoCycleShow = false;
        scope.popUp = false;
        scope.showCycling = false;
        scope.warningMessage = alerts.nonDigit;
        var onClickValue;


        scope.$on("dataLoaded", function() {
          // there is a slight delay for the controller to catch up so wait for it and load
          scope.delta_state = (scope.stage.auto_delta) ? "ON" : "OFF";
          scope.$watch('popUp', function(newVal) {
            popupStatus.popupStatusGatherData = scope.popUp;
          });

          scope.$watch('step.id', function(new_id) {

            if(scope.fabricStep) {
              $rootScope.$broadcast("event:step-selection-changed");
              /*if(scope.fabricStep.previousStep === null && scope.fabricStep.parentStage.previousStage === null) {
                $rootScope.$broadcast("event:first-step-selected");
              }

              if(scope.fabricStep.nextStep === null && scope.fabricStep.parentStage.nextStage === null) {
                $rootScope.$broadcast("event:last-step-selected");
              }*/
            }
          });

          scope.$watch('stage.stage_type', function(newVal, oldVal) {
            if(newVal === "cycling") {
              scope.showCycling = true;
              scope.cycleNoBackup = scope.stage.num_cycles;
            } else {
              scope.showCycling = false;
            }
          });

          scope.$watch("fabricStep.circle.holdTime.text", function(holdTime) {
            if(holdTime !== undefined) {
              if(holdTime === "∞") {
                scope.infiniteHoldStep = true;
                scope.infiniteHoldStage = true;
              } else {
                scope.infiniteHoldStep = false;
                scope.infiniteHoldStage = false;
              }
            }
          });
        });

        // focusElement is the classname of the desired input box to be shown
        scope.clickOnField = function(field, focusElement) {

          scope[field] = true;
          onClickValue = $('.' + focusElement).val();

          $('.' + focusElement).width($('.' + focusElement).parent().width()); // Set the width of the text field;
          if($('.' + focusElement).parent().width() < 30) {
            $('.' + focusElement).width(30);
          }

          console.log($('.' + focusElement).parent().width());
          if($('.' + focusElement).val() === "") {
            onClickValue = null;
          }
          // It takes while after render to focus, thats y we have a $timeout
          $timeout(function() {
            $('.' + focusElement).focus();
          });
        };

        scope.saveCycle = function() {

          scope.stageNoCycleShow = false;

          if(parseInt(onClickValue) !== parseInt(scope.stage.num_cycles)) {

            if(scope.stage.num_cycles >= scope.stage.auto_delta_start_cycle) {
              ExperimentLoader.saveCycle(scope).then(function () {
                $rootScope.$broadcast('cycle:number:updated', scope.stage.num_cycles);
              });
              scope.cycleNoBackup = scope.stage.num_cycles;
            } else {

              alerts.showMessage(alerts.noOfCyclesWarning, scope);
              scope.stage.num_cycles = scope.cycleNoBackup;
            }

          }
          noOfCycle = scope.stage.num_cycles;
        };

        scope.changeDelta = function() {

          if(scope.stage.stage_type === "cycling") {

            scope.stage.auto_delta = ! scope.stage.auto_delta;
            scope.delta_state = (scope.stage.auto_delta) ? "ON" : "OFF";
            ExperimentLoader.updateAutoDelata(scope).then(function() {
              console.log("Happy happy ---- Just testing ____-------______");
            });
          } else {
            // This part is no longer used as we dont show change auto delta for non cyclic stages.
            alerts.showMessage(alerts.autoDeltaOnWrongStage, scope);
          }
        };

        scope.saveStepName = function() {

          scope.step.name = (scope.step.name === "") ? null : scope.step.name;

          scope.stepNameShow = false;
          if(onClickValue !== scope.step.name) {
            ExperimentLoader.saveName(scope);
          }
        };

        scope.changeDuringStep = function() {

          scope.popUp = ! scope.popUp;
          scope.step.collect_data = ! scope.step.collect_data;
          ExperimentLoader.gatherDuringStep(scope);
        };

        scope.hidePopup = function() {
            scope.popUp = false;
        };

        scope.changeDuringRamp = function() {

          scope.popUp = ! scope.popUp;
          scope.step.ramp.collect_data = ! scope.step.ramp.collect_data;
          ExperimentLoader.gatherDataDuringRamp(scope);
        };

      }
    };
  }
]);
