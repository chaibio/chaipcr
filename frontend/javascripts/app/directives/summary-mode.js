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

window.ChaiBioTech.ngApp.directive('summaryMode', [
  'ExperimentLoader',
  function(ExperimentLoader) {
    return {
      restric: 'EA',
      replace: true,
      templateUrl: 'app/views/directives/summary-mode-general.html',
      scope: false,

      link: function(scope, elem, attr) {

        scope.$watch('summaryMode', function(summary) {

          if(! summary) {
            $(".data-box-container-summary-scroll").animate({
              left: "0"
            }, 500);

            $(".first-data-row").animate({
              left: "0"
            }, 500);

          } else {
            ExperimentLoader.getExperiment()
              .then(function(data) {
                var estimateTime = data.experiment.protocol.estimate_duration;
                scope.protocol.protocol.estimate_duration = estimateTime;
              });

            $(".data-box-container-summary-scroll").animate({
              left: "-=645"
            }, 500);

            $(".first-data-row").animate({
              left: "-=900"
            }, 500);

          }
        });

      }
    };
  }
]);
