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
  'User',
  '$state',
  'NetworkSettingsService',
  '$interval',
  '$timeout',
  function($scope, $rootScope, User, $state, NetworkSettingsService, $interval, $timeout) {

    $scope.wifiNetworks = {}; // All available wifi networks
    $scope.currentWifiSettings = {}; // Current active wifi network [connected to]
    $scope.ethernetSettings = {}; // Ethernet settings
    $scope.wirelessError = false;  // Incase no wifi adapter is present in the machine
    $scope.macAddress = NetworkSettingsService.macAddress || null;
    $scope.userSettings = $.jStorage.get('userNetworkSettings');
    $scope.wifiNetworkStatus = $scope.userSettings.wifiSwitchOn; // If network is on/off
    $scope.intervalKey = null;
    $scope.currentInterval = 1000;

    // Initiate wifi network service;
    if ($scope.userSettings.wifiSwitchOn) {
      NetworkSettingsService.getSettings(5000);
    }

    /**
      'new_wifi_result' this event is fired up when new wifi status is sent from the
      server.
    */
    $scope.$on('new_wifi_result', function() {

      $scope.wirelessError = false;
      $scope.wifiNetworkStatus = $scope.userSettings.wifiSwitchOn;
      $scope.currentWifiSettings = NetworkSettingsService.connectedWifiNetwork;
    });
    /**
      'ethernet_detected' this event is fired up when ethernet is detected in the machine.
    */
    $scope.$on('ethernet_detected', function() {
      $scope.ethernetSettings = NetworkSettingsService.connectedEthernet;
    });
    /**
      'wifi_adapter_error' this event is fired up when wifi adapter is not present or having some problem.
    */
    $rootScope.$on('wifi_adapter_error', function() {
      $scope.whenNoWifiAdapter();
    });
    /**
      'wifiNetworkStatus' This watch is executed when wifiNetworkStatus is changed, This one is changed when
      we toggle wifi on off switch. And to be executed switchStatus shouldbe inverse of the $scope.userSettings.wifiSwitchOn.
      This is enforced so that we dont have to call turnOnWifi() or turnOffWifi() at the page load.
    */
    $scope.$watch('wifiNetworkStatus', function(switchStatus) {

      if($scope.wirelessError === false) {
        if(switchStatus === true && $scope.userSettings.wifiSwitchOn === false) {
          $scope.turnOnWifi();
        } else if(switchStatus === false && $scope.userSettings.wifiSwitchOn === true) {
          NetworkSettingsService.stopInterval();
          $scope.turnOffWifi();
        }
      } else {
        NetworkSettingsService.stopInterval();
        NetworkSettingsService.getSettings(5000);
      }
    });

    $scope.$watch('wifiNetworks', function(network) {
      if($scope.wirelessError === false) {
        if($scope.wifiNetworkStatus === true) {
          if(network.length > 0 && ($scope.currentInterval == 1000 || $scope.intervalKey == null) ){
            $scope.stopInterval();
            $scope.currentInterval = 10000;
            $scope.intervalKey = $interval($scope.findWifiNetworks, $scope.currentInterval);
          } else if(network.length == 0 && ($scope.currentInterval == 10000 || $scope.intervalKey == null) ){
            $scope.stopInterval();
            $scope.currentInterval = 1000;
            $scope.intervalKey = $interval($scope.findWifiNetworks, $scope.currentInterval);
          }
        } else {
          $scope.stopInterval();
        }
      } else {
        $scope.stopInterval();      
      }
    });

    $scope.$on('wifi_adapter_reconnected', function(evt, wifiData) {
      $scope.wifiNetworkStatus = true;
      $scope.wirelessError = false;
      $scope.macAddress = wifiData.state.macAddress;
      $scope.init();
    });

    $scope.$on('wifi_stopped', function() {
      //console.log("wifi stopped");
      //scope.inProgress = false;
      //$timeout(function(){
        $scope.wifiNetworks = $scope.currentWifiSettings = {};
      //}, 1000);
    });
    /**
      This function takes care of the things when there is no wifi adapter or wifi adapter is having some error.
    */
    $scope.whenNoWifiAdapter = function() {

      $scope.wirelessError = true;
      $scope.wifiNetworkStatus = false;
      $scope.wirelessErrorData = NetworkSettingsService.wirelessErrorData;
      $scope.wifiNetworks = $scope.currentWifiSettings = {};
      $scope.userSettings.wifiSwitchOn = false;
      $.jStorage.set('userNetworkSettings', $scope.userSettings);
    };

    /**
      This methode turns off wifi, It empties wifiNetworks and currentWifiSettings, So that immediately
      interface changes. It also reloads userSettings from localstorage.
    */
    $scope.turnOffWifi = function() {

      var stopped = NetworkSettingsService.stop();
      $scope.wifiNetworks = $scope.currentWifiSettings = {};
      stopped.then(function(result) {
        $scope.userSettings = $.jStorage.get('userNetworkSettings');
        $state.go('settings.networkmanagement');
      }, function(err) {
        console.log("Could not disconnect wifi", err);
      });
    };

    /**
      This method starts the wifi, Then calls init() and brings the network data and reloads userSettings
      from localstorage
    */
    $scope.turnOnWifi = function() {

      var started = NetworkSettingsService.restart();
      started.then(function(result) {
        $scope.userSettings = $.jStorage.get('userNetworkSettings');
        $scope.init();
      }, function(err) {
        NetworkSettingsService.processOnError(err);
        console.log("Could not connect wifi", err);
      });
    };

    /**
      This method looks for all the wifi networks around the vicinity and add them to wifiNetworks
    */
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

    $scope.stopInterval = function() {
      $interval.cancel($scope.intervalKey);
      $scope.intervalKey = null;
    };


    /**
      This part of the code look at the wifi networks around at every 10 second, There could be changes in the network.
      Like change in signal stregth, some new networks or some networks may not be there.
    */
    /*var stop = $interval(function() {

      if($state.is('settings.networkmanagement')) {
        $scope.findWifiNetworks();
      } else {
        $interval.cancel(stop);
        stop = null;
      }
    }, 5000); */

    /**
      Initiate the primary things like ethernet status, wifiNetworkStatus and all the wifi networks around the room.
    */
    $scope.init = function() {
      console.log("Initing");
      NetworkSettingsService.getEthernetStatus();

      if(NetworkSettingsService.wirelessError) {
        $scope.whenNoWifiAdapter();
        return;
      }

      if($scope.userSettings.wifiSwitchOn) {
        if(NetworkSettingsService.intervalKey === null) {
          NetworkSettingsService.getSettings(5000);
        }

        $scope.currentWifiSettings = NetworkSettingsService.connectedWifiNetwork;
        $scope.intervalKey = $interval($scope.findWifiNetworks, $scope.currentInterval);
        // If we refresh right on this page, mac address may take some time to load in service , so we wait to load here.
        if($scope.macAddress === null && NetworkSettingsService.wirelessError === true) {
          var waitForMac = $interval(function() {            
            if(NetworkSettingsService.macAddress !== null) {
              $scope.macAddress = NetworkSettingsService.macAddress;
              $interval.cancel(waitForMac);
              waitForMac = null;
            }
          }, 1000);
        }
      }
    };

    $scope.init();
  }
]);
