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

window.ChaiBioTech.ngApp.directive('startOnCycle', [
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
        delta: '=',
        action: '&' // Learn how to pass value in this scenario
      },
      templateUrl: 'app/views/directives/edit-value.html',

      link: function(scope, elem, attr) {

        scope.edit = false;
        var editValue;

        scope.$watch("reading", function(val) {

          if(angular.isDefined(scope.reading)) {

            scope.shown = Number(scope.reading);
            scope.hidden = Number(scope.reading);
          }
        });

        scope.editAndFocus = function(className) {

          if(scope.delta) {
            editValue = Number(this.hidden);
            scope.edit = ! scope.edit;
            $timeout(function() {
              $('.' + className).focus();
            });
          }
        };

        scope.save = function() {

          scope.edit = false;
          if(! isNaN(scope.hidden)) {

            if(Number(scope.hidden) <= 0) {

              scope.hidden = scope.shown;
              var warningMessage0 = alerts.startOnCycleMinimum;
              scope.$parent.showMessage(warningMessage0);

            } else if(Number(scope.hidden) <= Number(scope.$parent.stage.num_cycles)) {

              if(editValue !== Number(scope.hidden)) {
                scope.reading = scope.hidden;
                $timeout(function() {
                  ExperimentLoader.changeStartOnCycle(scope.$parent).then(function(data) {
                    console.log(data);
                  });
                });
              }

            } else {

              scope.hidden = scope.shown;
              var warningMessage1 = alerts.startOnCycleWarning;
              scope.$parent.showMessage(warningMessage1);
            }

          } else {

            scope.hidden = scope.shown;
          }

          /*scope.edit = false;
          if(scope.reading <= scope.$parent.stage.num_cycles) {
            ExperimentLoader.changeStartOnCycle(scope.$parent);
          }*/

        };
      }
    };
  }
]);
