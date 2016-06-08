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
  '$rootScope',
  '$stateParams',
  'User',
  '$state',
  'NetworkSettingsService',
  function($scope, $rootScope, $stateParams, User, $state, NetworkSettingsService) {

    $scope.wifiNetworks = {};
    $scope.currentWifiSettings = {};
    $scope.ethernetSettings = {};
    $scope.wirelessError = false;

    $scope.wifiNetworkStatus = ""; // If network is on/off

    $scope.$on('new_wifi_result', function() {
      $scope.wifiNetworkStatus = true;
      $scope.wirelessError = false;
      $scope.currentWifiSettings = NetworkSettingsService.connectedWifiNetwork;
    });

    $scope.$on('ethernet_detected', function() {
      $scope.ethernetSettings = NetworkSettingsService.connectedEthernet;
    });

    $rootScope.$on('wifi_adapter_error', function() {
      $scope.wifiNetworkStatus = false;
      $scope.wirelessError = true;
      $scope.wirelessErrorData = NetworkSettingsService.wirelessErrorData;
      $scope.wifiNetworks = {};
      $scope.currentWifiSettings = {};
    });

    $scope.findWifiNetworks = function() {
      if(! NetworkSettingsService.wirelessError) {
        NetworkSettingsService.getWifiNetworks().then(function(result) {
          if(result.data) {
            $scope.wifiNetworks = result.data.scan_result;
          }

        });
      }
    };

    $scope.getSettings = function() {

      NetworkSettingsService.getInitialStatus().then(function(result) {
        $scope.wifiNetworkStatus = true;
        $scope.currentNetwork = result.data;
      }, function(err) {
        $scope.wifiNetworkStatus = false;
      });
    };

    $scope.getSettings();
    NetworkSettingsService.getEtherNetStatus();
    $scope.currentWifiSettings = NetworkSettingsService.connectedWifiNetwork;
    $scope.findWifiNetworks();

  }
]);
