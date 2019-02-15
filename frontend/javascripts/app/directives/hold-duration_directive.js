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

window.ChaiBioTech.ngApp.directive('holdDuration', [
  'ExperimentLoader',
  '$timeout',
  'alerts',
  '$uibModal',
  'TimeService',
  '$rootScope',
  function(ExperimentLoader, $timeout, alerts, $uibModal, TimeService, $rootScope) {
    return {
      restric: 'EA',
      replace: true,
      scope: {
        caption: "@",
        unit: "@",
        reading: '=',
        pause: '=',
        helpText: "@"
      },
      templateUrl: 'app/views/directives/edit-value.html',

      link: function(scope, elem, attr) {

        scope.edit = false;
        scope.delta = false; // This is to prevent the directive become disabled, check delta in template, this is used for auto delta field
        var editValue = null, help_part = angular.element(elem).find(".help-part");

        scope.$watch("reading", function(val) {

          if(angular.isDefined(scope.reading)) {
            scope.shown = TimeService.newTimeFormatting(scope.reading);
          }
        });

        scope.$watch("pause", function(val) {

          if(angular.isDefined(scope.pause)) {
            scope.delta = scope.pause;
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

        scope.ifLastStep = function() {

          var myCircle = scope.$parent.fabricStep.circle;          
          return myCircle.next === null;
        };

        scope.editAndFocus = function(className) {

          scope.edit = true;
          editValue = TimeService.convertToSeconds(scope.shown);
        };

        scope.save = function() {

          scope.edit = false;
          var newHoldTime = TimeService.convertToSeconds(scope.shown);

          //console.log(newHoldTime, editValue);
          /*if((newHoldTime || newHoldTime === 0) && editValue != newHoldTime) {*/
          
          if(!isNaN(newHoldTime) && scope.reading != newHoldTime) {

            if(Number(newHoldTime) < 0) {
              alerts.showMessage(alerts.noNegativeHold, scope);
            } else if(Number(newHoldTime) === 0 ) {
              if(scope.ifLastStep() && ! scope.$parent.step.collect_data) {
                scope.reading = newHoldTime;
                $timeout(function() {
                  ExperimentLoader.changeHoldDuration(scope.$parent).then(function(data) {
                    console.log(data);
                  });
                });
              } else {
                scope.reading = newHoldTime;
                alerts.showMessage(alerts.holdDurationZeroWarning, scope);
              }
            } else {
              $timeout(function() {
                scope.reading = newHoldTime;
                $timeout(function() {
                  ExperimentLoader.changeHoldDuration(scope.$parent).then(function(data) {
                    console.log(data, scope);
                  });
                });
              });
            }

            editValue = newHoldTime;
          }
          scope.shown = TimeService.newTimeFormatting(scope.reading);
        };
      }
    };
  }
]);
