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

window.ChaiBioTech.ngApp.directive('time', [
  'ExperimentLoader',
  '$timeout',
  'TimeService',
  function(ExperimentLoader, $timeout, TimeService) {
    return {
      restric: 'EA',
      replace: true,
      scope: {
        caption: "@",
        //unit: "@",
        reading: '=',
        delta: '=',
        action: '&' // Learn how to pass value in this scenario
      },

      transclude: true,
      templateUrl: 'app/views/directives/temp-time.html',

      link: function(scope, elem, attr) {

        var editValue = null;
        scope.showCapsule = true;

        scope.$watch("reading", function(val) {

          if(angular.isDefined(scope.reading)) {
            scope.shown = TimeService.newTimeFormatting(scope.reading);
          }
        });

        scope.editAndFocus = function(className) {

          if(scope.delta) {
            editValue = scope.$parent.convertToSeconds(scope.shown);
          }
        };

        scope.save = function() {

          var newHoldTime = scope.$parent.convertToSeconds(scope.shown);
          console.log(newHoldTime);
          if((newHoldTime || newHoldTime === 0) && editValue != newHoldTime) {
            scope.reading = newHoldTime;
            $timeout(function() {
              ExperimentLoader.changeDeltaTime(scope.$parent).then(function(data) {
                console.log(data);
              });
            });
            editValue = newHoldTime;
          }
          scope.shown = scope.$parent.newTimeFormatting(scope.reading);
        };
      }
    };
  }
]);
