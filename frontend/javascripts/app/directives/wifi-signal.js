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

angular.module('ChaiBioTech').directive('wifiSignal', [
  '$state',
  function($state) {
    return {
      templateUrl: 'app/views/directives/wifi-signal.html',
      restric: 'E',
      //replace: true,
      scope: {
        ssid: "@ssid",
        quality: "@quality"
      },

      link: function(scope, element, attr) {

        scope.arc4Signal = true;
        scope.arc3Signal = false;
        scope.arc2Signal = false;
        scope.arc1Signal = false;
        scope.selected = false;

        if($state.is('settings.networkmanagement.wifi')) {
          if($state.params.name === scope.ssid) {
            scope.selected = true;
          } else {
            scope.selected = false;
          }
        }

        scope.$on('$stateChangeStart', function(event, toState, toParams) {

          if(toParams.name === scope.ssid) {
            scope.selected = true;
          } else {
            scope.selected = false;
          }
        });

        scope.$watch("quality", function() {
          var quality = scope.quality;
          scope.rerender(Number(quality));
        });

        scope.rerender = function(quality) {
          if(quality && Number(quality) <= 100) {
            if(quality > 90) {
              scope.arc1Signal = true;
            }
            if(quality > 50) {
              scope.arc2Signal = true;
            }
            if(quality > 25) {
              scope.arc3Signal = true;
            }
            if(quality > 0) {
              scope.arc4signal = true;
            }
          }
        };

      }
    };
  }
]);
