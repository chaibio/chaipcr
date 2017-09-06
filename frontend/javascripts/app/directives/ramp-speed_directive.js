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

window.ChaiBioTech.ngApp.directive('rampSpeed', [
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
        helpText: "@"
      },
      templateUrl: 'app/views/directives/edit-value.html',

      link: function(scope, elem, attr) {

        scope.edit = false;
        scope.delta = true; // This is to prevent the directive become disabled, check delta in template, this is used for auto delta field
        scope.ramp = true;
        scope.pause = true; // Not bothered about pause value; this need a change in the update, now I have a better picture.
        var editValue, help_part = angular.element(elem).find(".help-part");

        scope.$watch("reading", function(val) {

          if(angular.isDefined(scope.reading)) {
            scope.configureData();
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

        scope.configureData = function() {

          if(Number(scope.reading) <= 0) {
            scope.shown = Number(5.0);
            scope.unit = " ºC/s";
          } else {
            scope.shown = scope.reading;
            scope.unit = " ºC/s";
          }
          editValue = scope.shown;
        };


        scope.editAndFocus = function(className) {

          scope.edit = true;
          if(scope.shown === 5) {
            scope.shown = editValue = Number(5);
            scope.unit = " ºC/s";
          } else {
            scope.shown = editValue = Number(scope.shown);
          }


        };

        scope.save = function() {

          scope.edit = false;

          var fractionLength  = (String(scope.shown).split('.')[1] || 0).length;

          if(fractionLength > 5) {
            console.log("Limit exceeded", fractionLength);
            scope.configureData();
            var warningMessageLimitExceeded = alerts.rampSpeedWarningLimitExceeded;
            alerts.showMessage(warningMessageLimitExceeded, scope);
            return;

          } else if(! isNaN(scope.shown) && Number(scope.shown) < 6 && Number(scope.shown) >= 0) {

            if(editValue != Number(scope.shown)) {

              scope.shown = scope.reading = (Number(scope.shown));
							if(scope.shown === 0){
								scope.shown = scope.reading = 5;
							}

              $timeout(function() {
                ExperimentLoader.changeRampSpeed(scope.$parent).then(function(data) {
                  console.log(data);
                });
              });
            }
            scope.configureData();
            return ;
          }

          scope.configureData();
          var warningMessage = alerts.rampSpeedWarning;
          alerts.showMessage(warningMessage, scope);
        };
      }
    };
  }
]);
