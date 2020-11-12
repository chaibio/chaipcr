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

window.ChaiBioTech.ngApp.directive('temperature', [
  'ExperimentLoader',
  '$timeout',
  'alerts',
  function(ExperimentLoader, $timeout, alerts) {
    return {
      restric: 'EA',
      replace: true,
      scope: {
        caption: "@",
        unit: "@",
        reading: '=',
        action: '&', // Learn how to pass value in this scenario
        helpText: "@"
      },

      templateUrl: 'app/views/directives/edit-value.html',

      link: function(scope, elem, attr) {

        scope.delta = true; // This is to prevent the directive become disabled, check delta in template, this is used for auto delta field
        scope.edit = false;
        scope.temp = true;
        scope.pause = true; // Not bothered about pause value;

        var editValue, help_part = angular.element(elem).find(".help-part");

        scope.$watch("reading", function(val) {

          if(angular.isDefined(scope.reading)) {
            scope.shown = Number(scope.reading).toFixed(1);
          }
        });

        scope.$watch("edit", function(editStatus) {

          if(editStatus === true) {
            help_part.animate({
              left: 100
            }, 200);
          } else if(editStatus === false) {
            help_part.animate({
              left: 0
            }, 200);
          }
        });

        scope.editAndFocus = function(className) {
          if(scope.edit === false) {
            scope.edit = true;
            editValue = Number(scope.shown).toFixed(1);
          }

        };

        scope.save = function() {
          scope.edit = false;
          if(scope.$parent.step.hold_time >= 7200 && Number(scope.shown) < 20){
            alerts.showMessage(alerts.holdLess20DurationWarning, scope);
            scope.shown = Number(scope.reading).toFixed(1);
          } else if (scope.$parent.step.hold_time == 0 && Number(scope.shown) < 20) {
            alerts.showMessage(alerts.holdLess20DurationZeroWarning, scope);
            scope.shown = Number(scope.reading).toFixed(1);
          } else if(! isNaN(scope.shown) && editValue != Number(scope.shown)) {
            scope.reading = Number(scope.shown).toFixed(1);
            $timeout(function() {
              ExperimentLoader.changeTemperature(scope.$parent).then(function(data) {
                console.log(data);
              });
            });

          } else {
            scope.shown = Number(scope.reading).toFixed(1);
          }
        };
      }
    };
  }
]);
