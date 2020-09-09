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

angular.module('ChaiBioTech').directive("wifiCheckSymbol", [
  '$rootScope',
  'NetworkSettingsService',
  '$state',
  function($rootScope, NetworkSettingsService, $state) {
    return {
      restrict: "E",
      replace: true,
      template: '<div class="check-symbol"><img src="/images/WhiteCheckGreenRing.svg"></div>',
      scope: {
        currentNetwork: "=currentNetwork",
        ssid: "@ssid"
      },

      link: function(scope, elem, attrs) {

        angular.element(elem).removeClass('active');
        scope.connected = false;
        scope.selected = false;
        scope.$watch('currentNetwork', function(data) {
          if(data.state) {
            scope.verify();
          }
        });
        scope.setSelected = function(myName, _ssid) {
          if(myName === _ssid) {
            scope.selected = true;
          } else {
            scope.selected = false;
          }
        };

        if($state.is('settings.networkmanagement.wifi')) {
          var _ssid = scope.ssid.replace(new RegExp(" ", "g"), "_");
          scope.setSelected($state.params.name, _ssid);
        }

        scope.$on('$stateChangeStart', function(event, toState, toParams) {
          var _ssid = scope.ssid.replace(new RegExp(" ", "g"), "_");
          scope.setSelected(toParams.name, _ssid);
        });

        scope.$on("new_wifi_result", function() {
          scope.currentNetwork = NetworkSettingsService.connectedWifiNetwork;
          scope.verify();
        });

        scope.verify = function() {

          var state = scope.currentNetwork.state;
          if(state && state.status === "connected") {
            var _ssid = scope.currentNetwork.settings["wpa-ssid"] || scope.currentNetwork.settings.wireless_essid;
            var connectedNetworkSsid = _ssid.replace(new RegExp('"', 'g'), "");
            if(connectedNetworkSsid === scope.ssid) {
              angular.element(elem).addClass('active');
              scope.connected = true;
            } else {
              angular.element(elem).removeClass('active');
            }
            return;
          }
          angular.element(elem).removeClass('active'); // If not connected, hide it.
        };
      }

    };
  }
]);
