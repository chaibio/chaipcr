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

window.ChaiBioTech.ngApp.controller('selectedNetwork', [
  '$scope',
  '$stateParams',
  'User',
  '$state',
  'NetworkSettingsService',
  function($scope, $stateParams, User, $state, NetworkSettingsService) {

    $scope.name = $state.params.name.replace(new RegExp("_", "g"), " ");
    $scope.buttonValue = "CONNECT";
    $scope.IamConnected = false;
    $scope.statusMessage = "";
    $scope.currentNetwork = {};
    $scope.autoSetting = "auto"; // This variable controls set auto/manual.

    $scope.$watch('autoSetting', function(val, oldVal) {
        console.log(val);
    });

    $scope.$on('new_wifi_result', function() {

      if(NetworkSettingsService.currentNetwork.state.status === "connected") {
        $scope.statusMessage = "";
        $state.go('settings.networkmanagement');
      } else {
        $scope.configureAsStatus(NetworkSettingsService.currentNetwork.state.status);
      }
    });

    $scope.credentials = {
      'wpa-ssid': $scope.name,
      'wpa-psk': "",
      'type': "dhcp"
    };

    var wifiConnection = NetworkSettingsService.connectedWifiNetwork;
    if(wifiConnection.settings && wifiConnection.settings["wpa-ssid"]) {
      $scope.connectedSsid = wifiConnection.settings["wpa-ssid"].replace(new RegExp('"', "g"), "");
      if($state.params.name.replace(new RegExp('_', "g"), " ") === $scope.connectedSsid) {
        if(wifiConnection.state.status === "connected") {
          $scope.currentNetwork = wifiConnection;
          $scope.IamConnected = true;
        }
      }
    }

    var ethernetConnection = NetworkSettingsService.connectedEthernet;
    if(ethernetConnection.state) {
      if($state.params.name.replace(new RegExp('_', "g"), " ") === "ethernet") {
        $scope.IamConnected = true;
        $scope.currentNetwork = ethernetConnection;
      }
    }

    $scope.connectWifi = function() {
      NetworkSettingsService.connectWifi($scope.credentials).then(function(data) {
        $scope.statusMessage = "";
        $scope.buttonValue = "CONNECTING";
      }, function(err) {
        console.log(err);
      });
    };

    $scope.configureAsStatus = function(status) {

      switch (status) {
        case "not_connected":
          $scope.buttonValue = "CONNECT";
          $scope.statusMessage = "";
          break;
        case "connecting":
          $scope.buttonValue = "CONNECTING";
          break;
        case "connection_error":
          $scope.buttonValue = "CONNECT";
          $scope.statusMessage = "Monkeys broke in and broke the cable. Couldn't connect";
          break;
        case "authentication_error":
          $scope.buttonValue = "CONNECT";
          $scope.statusMessage = "Monkeys broke in and stole everything. Couldn't connect";
          break;
      }
    };

  }
]);
