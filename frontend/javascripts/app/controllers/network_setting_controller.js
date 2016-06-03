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

window.ChaiBioTech.ngApp.controller('NetworkSettingController', [
  '$scope',
  '$stateParams',
  'User',
  '$state',
  'NetworkSettingsService',
  function($scope, $stateParams, User, $state, NetworkSettingsService) {

    $scope.wifiNetworks = {};
    $scope.curreWifiSettings = {};
    $scope.ethernetSettings = {};

    $scope.$on('new_wifi_result', function() {
      $scope.curreWifiSettings = NetworkSettingsService.connectedWifiNetwork;
    });

    $scope.$on('ethernet_detected', function() {
      $scope.ethernetSettings = NetworkSettingsService.connectedEthernet;
    });

    $scope.findWifiNetworks = function() {
      console.log("called up");
      NetworkSettingsService.getWifiNetworks().then(function(result) {
        if(result.data) {
          $scope.wifiNetworks = result.data.scan_result;
        }

      });
    };

    $scope.getSettings = function() {
        /*NetworkSettingsService.getSettings().then(function(result) {
          console.log(result);
          if(result.data.settings) {
            $scope.currentNetwork = result.data;
          }
        });*/
        //NetworkSettingsService.getSettings();
    };

    $scope.findWifiNetworks();
    $scope.getSettings();
    NetworkSettingsService.getEtherNetStatus();
  }
]);
