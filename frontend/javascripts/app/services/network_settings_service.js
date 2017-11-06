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

window.ChaiBioTech.ngApp.service('NetworkSettingsService',[
  '$rootScope',
  '$http',
  '$q',
  'host',
  '$interval',
  'Webworker',
  function($rootScope, $http, $q, host, $interval, Webworker) {

    var that = this, previousSsid = null;
    this.connectedWifiNetwork = {}; // If we have connected/been trying  to a particular network
    this.connectedEthernet = {}; // Ethernet which we are connected
    this.wirelessError = false; // If we dont have a wireless connection
    this.wirelessErrorData = {}; // Data from server while we dont have wifi network
    this.previousConnectionStatus = null; // Connection Status at the moment
    this.userSettings = $.jStorage.get('userNetworkSettings');
    this.intervalKey = null;
    this.listofAllWifi = {};
    this.wifiShutDownInProgress = false;
    this.wifiRestartingInProgress = false;
    this.macAddress = null;
    
    this.getWifiNetworks = function() {

      var delay = $q.defer();
      $http.get(host + ':8000/network/wlan/scan').then(function(scanOutput) {
        scanOutput.data.scan_result.forEach(function(network) {
          that.listofAllWifi[network.ssid] = network;
        });
        delay.resolve(scanOutput);
      }, function(err) {
        delay.reject(err);
      });
      return delay.promise;
    };

    this.getSettings = function() {

      this.userSettings = $.jStorage.get('userNetworkSettings');
      this.accessLanLookup();

      this.intervalKey = $interval(that.accessLanLookup, 2000);
    };

    this.accessLanLookup = function() {
      if(this.userSettings.wifiSwitchOn /*&& that.wirelessError === false*/) {
        this.lanLookup();
      }
    };

    this.lanLookup = function() {

      $http.get(host + ':8000/network/wlan')
      .then(function(result) {
        that.processData(result);
      }, function(err) {
        that.processOnError(err); // in case error ,May be no wireless interface
      });
    };

    this.processData = function(wlanOutput) {

      console.log("processing");
      if(this.wirelessError && wlanOutput.data.settings) {
        console.log("No more error");
        this.wirelessError = false;
        $rootScope.$broadcast("wifi_adapter_reconnected", wlanOutput.data);
      }

      if(wlanOutput.data.settings) {

        this.connectedWifiNetwork = wlanOutput.data;

        if(this.macAddress === null) {
          this.macAddress = wlanOutput.data.state.macAddress;
        }

        var _ssid = wlanOutput.data.settings["wpa-ssid"] || wlanOutput.data.settings.wireless_essid;
        var _connectionStatus = wlanOutput.data.state.status;

        if(previousSsid !== _ssid || this.previousConnectionStatus !== _connectionStatus) {
          previousSsid = _ssid;
          this.previousConnectionStatus = _connectionStatus;
          $rootScope.$broadcast("new_wifi_result");
        }
      }

    };

    this.processOnError = function(err) {

      previousSsid = this.previousConnectionStatus = null;
      this.connectedWifiNetwork = {};
      this.wirelessError = true;

      if(err.data && err.data.status) {
        this.wirelessErrorData = err.data.status;
      }

      $rootScope.$broadcast("wifi_adapter_error");
    };

    this.getReady = function() {

      $http.get(host + ':8000/network/wlan')
      .then(function(result) {
        console.log(result.data, "bing");
        if(! result.data.state) {
          return null;
        }
        if(result.data.state.status) {
          that.macAddress = result.data.state.macAddress;
        }
      }, function(err) {
        that.processOnError(err); // in case error ,May be no wireless interface
      });
    };

    this.getEthernetStatus = function() {

      $http.get(host + ':8000/network/eth0')
      .then(function(ethernet) {
        that.connectedEthernet = ethernet.data;
        if(ethernet.data.state.address) {
          $rootScope.$broadcast("ethernet_detected");
        }
      });
    };

    /**
      This method connects to particular network according to the connectionParams content.
      @params connectionParams an object contains ssid and passkey.
    */
    this.connectWifi = function(connectionParams) {

      var delay = $q.defer();
      $http.put(host + ':8000/network/wlan', connectionParams)
      .then(function(result) {
        delay.resolve(result);
      }, function(err) {
        delay.reject(err);
      });

      return delay.promise;
    };

    this.connectToEthernet = function(ethernetParams) {

      var delay = $q.defer();
      ethernetParams.type = "static";
      $http.put(host + ':8000/network/eth0', ethernetParams)
      .then(function(result) {
        console.log("New ethernet connection");
        //result = ethernetParams;
        console.log("data I need", result);
        delay.resolve(result);
      }, function(err) {
        delay.reject(err);
      });

      return delay.promise;
    };

    this.changeToAutomatic = function(ethernet) {

      ethernet.type = "dhcp";
      var delay = $q.defer();
      $http.put(host + ':8000/network/eth0', ethernet)
      .then(function(result) {
        console.log("New ethernet connection");
        //result = ethernetParams;
        console.log("data I need", result);
        delay.resolve(result);
      }, function(err) {
        delay.reject(err);
      });
      return delay.promise;
    };

    this.stop = function() {

      var delay = $q.defer();
      $http.post(host + ':8000/network/wlan/disconnect')
      .then(function(result) {
        that.previousConnectionStatus = previousSsid = null;
        that.connectedWifiNetwork = {};
        that.userSettings.wifiSwitchOn = false;
        $.jStorage.set('userNetworkSettings', that.userSettings);
        $rootScope.$broadcast("wifi_stopped");
        delay.resolve(result);
      }, function(err) {
        delay.reject(err);
      });

      return delay.promise;
    };

    this.restart = function() {

      var delay = $q.defer();
      $http.post(host + ':8000/network/wlan/connect')
      .then(function(result) {
        that.userSettings.wifiSwitchOn = true;
        that.wirelessError = false;
        $.jStorage.set('userNetworkSettings', that.userSettings);
        $rootScope.$broadcast("wifi_restarted");
        delay.resolve(result);
      }, function(err) {
        delay.reject(err);
      });

      return delay.promise;
    };

    this.stopInterval = function() {
      $interval.cancel(this.intervalKey);
      this.intervalKey = null;
    };

    // We need to make sure that, we call /network api only when we are in
    // /settings/networkmanagement
    $rootScope.$on("$stateChangeStart", function(event, toState) {
      // If we are not in the network settings part, we dont have to query /network anymore
      if(toState.name !== "settings.networkmanagement" && toState.name !== "settings.networkmanagement.wifi") {
        that.stopInterval();
      }
    });
  }
]);
