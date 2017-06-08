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

window.ChaiBioTech.ngApp.directive('summaryModeItem', [
  'ExperimentLoader',
  function(ExperimentLoader) {

    return {
      restric: 'EA',
      replace: true,
      scope: {
        caption: "@",
        reading: '@'
      },

      templateUrl: 'app/views/directives/summary-mode-item.html',


      link: function(scope, elem, attr) {


        if(scope.caption.length > 15) {
          $(elem).find(".caption-part").css("font-size", "14px");
        }

        scope.delta = true;
        scope.date = false;
        scope.$watch("reading", function(val) {
          scope.data = scope.reading;

          if(angular.isDefined(scope.reading)) {
            if(scope.caption === "Created on") {
              scope.date = true;
              //timeFormat.getForSummaryMode(scope.reading);
              //scope.data = (scope.reading).replace("T", ",").slice(0, -8);
            } else if(scope.caption === "Run on") {
              scope.date = true;
            }
          }

        });

      }
    };
  }
]);
