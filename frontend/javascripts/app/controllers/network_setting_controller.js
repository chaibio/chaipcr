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
  '$interval',
  function($scope, $rootScope, $stateParams, User, $state, NetworkSettingsService, $interval) {

    $scope.wifiNetworks = {}; // All available wifi networks
    $scope.currentWifiSettings = {}; // Current active wifi network [connected to]
    $scope.ethernetSettings = {}; // Ethernet settings
    $scope.wirelessError = false;  // Incase no wifi adapter is present in the machine
    $scope.wifiNetworkStatus = null; // If network is on/off
    $scope.userSettings = $.jStorage.get('userNetworkSettings');

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

    $scope.$watch('wifiNetworkStatus', function(val) {

      if(val) {
        $scope.turnOnWifi();
        return;
      }

      $scope.turnOffWifi();
    })

    $scope.turnOffWifi = function() {

      var stopped = NetworkSettingsService.stop();
      stopped.then(function(result) {
        $scope.wifiNetworks = $scope.currentWifiSettings = {};
        $scope.userSettings = $.jStorage.get('userNetworkSettings');
        $state.go('settings.networkmanagement');
      }, function(err) {
        console.log("Could not disconnect wifi", err);
      });
    };

    $scope.turnOnWifi = function() {

      var started = NetworkSettingsService.restart();
      started.then(function(result) {
        $scope.userSettings = $.jStorage.get('userNetworkSettings');
        $scope.init();
      }, function(err) {
        console.log("Could not connect wifi", err);
      });
    };

    $scope.findWifiNetworks = function() {

      if(! NetworkSettingsService.wirelessError && $scope.userSettings.wifiSwitchOn) {
        NetworkSettingsService.getWifiNetworks()
        .then(function(result) {
          if(result.data) {
            $scope.wifiNetworks = result.data.scan_result;
          }
        });
      }
    };

    var stop = $interval(function() {

      if($state.is('settings.networkmanagement')) {
        $scope.findWifiNetworks();
      } else {
        $interval.cancel(stop);
        stop = null;
      }
    }, 10000);

    $scope.getSettings = function() {
      // We may need this method when we refresh right on this page.
      if($scope.wifiNetworkStatus === null) {
        NetworkSettingsService.getInitialStatus()
        .then(function(result) {
          $scope.wifiNetworkStatus = true;
          $scope.currentNetwork = result.data;
        }, function(err) {
          $scope.wifiNetworkStatus = false;
        });
      }
    };

    $scope.init = function() {

      if($scope.userSettings.wifiSwitchOn) {
        $scope.getSettings();
        $scope.currentWifiSettings = NetworkSettingsService.connectedWifiNetwork;
        $scope.findWifiNetworks();
      }
      NetworkSettingsService.getEtherNetStatus();
    };

    $scope.init();
  }
]);
