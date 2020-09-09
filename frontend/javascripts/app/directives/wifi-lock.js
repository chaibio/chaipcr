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

angular.module('ChaiBioTech').directive('wifiLock', [
  '$rootScope',
  '$state',
  function($rootScope, $state) {
    return {
      templateUrl: 'app/views/directives/wifi-lock.html',
      restric: 'E',
      //replace: true,
      scope: {
        encryption: "@encryption",
        ssid: "@ssid"
      },

      link: function(scope, element, attr) {

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

        scope.$watch("encryption", function(val) {
          if(scope.encryption === "" || scope.encryption === "none" ) {
            angular.element(element).css('opacity', '0');
          }
        });
        }
    };
  }
]);
