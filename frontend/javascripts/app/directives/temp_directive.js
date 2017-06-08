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

window.ChaiBioTech.ngApp.directive('temp', [
  'ExperimentLoader',
  '$timeout',
  'alerts',
  '$uibModal',
  function(ExperimentLoader, $timeout, alerts, $uibModal) {
    return {
      restric: 'EA',
      replace: true,
      scope: {
        caption: "@",
        unit: "@",
        reading: '=',
        delta: '=',
        action: '&'
      },
      templateUrl: 'app/views/directives/temp-time.html',
      transclude: true,

      link: function(scope, elem, attr) {

        scope.edit = false;
        scope.showCapsule = true;
        var editValue,
        input_data_part = angular.element(elem).find(".input-data-part");

        scope.$watch("reading", function(val) {

          if(angular.isDefined(scope.reading)) {
            editValue = Number(scope.reading);
            scope.shown = Number(scope.reading).toFixed(1);
          }
        });

        scope.editAndFocus = function(className) {

          if(scope.delta) {
            scope.shown = Number(scope.reading).toFixed(1);
            editValue = Number(scope.shown);
            scope.edit = true;
            input_data_part.focus();
          }
        };

        scope.save = function() {

          scope.edit = false;
          if(! isNaN(scope.shown) && Number(scope.shown) < 100 && Number(scope.shown) > -100) {
            if(editValue !== Number(scope.shown)) {
              scope.reading = scope.shown;
              $timeout(function() {
                ExperimentLoader.changeDeltaTemperature(scope.$parent).then(function(data) {
                  console.log(data);
                });
              });
              return true;
            }
          } else {
            alerts.showMessage(alerts.autoDeltaTemp, scope);
          }
          scope.shown = Number(scope.reading).toFixed(1);
        };
      }
    };
  }
]);
