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

window.ChaiBioTech.ngApp.directive('arrow', [
  'ExperimentLoader',
  'canvas',
  function(ExperimentLoader, canvas) {

    return {
      restric: 'EA',
      replace: true,
      scope: false,
      templateUrl: 'app/views/directives/arrow.html',
      link: function(scope, elem, attr) {

        $(elem).click(function() {

          var action = $(this).attr('action');

          if(action === "previous") {
            scope.managePrevious(scope.fabricStep);
            return 0;
          }
            scope.manageNext(scope.fabricStep);
        });

        scope.manageNext = function(step) {

          var circle;
          if(step.nextStep) {
            circle = step.nextStep.circle;
            circle.manageClick();
            scope.applyValues(circle);
          } else if(step.parentStage.nextStage){
            circle = step.parentStage.nextStage.childSteps[0].circle;
            circle.manageClick();
            scope.applyValuesFromOutSide(circle);
          }
        };

        scope.managePrevious = function(step) {

          var circle, stage;
          if(step.previousStep) {
            circle = step.previousStep.circle;
            circle.manageClick();
            scope.applyValues(circle);
          } else if(step.parentStage.previousStage) {
            stage = step.parentStage.previousStage;
            circle = stage.childSteps[stage.childSteps.length - 1].circle;
            circle.manageClick();
            scope.applyValuesFromOutSide(circle);
          }
        };

      }
    };
  }
]);
