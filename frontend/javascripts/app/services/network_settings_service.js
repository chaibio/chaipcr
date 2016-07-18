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

    var that = this, ssid = null;
    this.connectedWifiNetwork = {}; // If we have connected to a particular network
    this.connectedEthernet = {}; // Ethernet which we are connected
    this.wirelessError = false; // If we daont have a wireless connection
    this.wirelessErrorData = {}; // Data from server while we dont have wifi network
    this.connectionStatus = null; // Connection Status at the moment
    this.userSettings = $.jStorage.get('userNetworkSettings');
    this.intervalKey = null;
    this.listofAllWifi = {};

    this.getWifiNetworks = function() {

      var delay = $q.defer();
      $http.get(host + ':8000/network/wlan/scan').then(function(data) {
        var listofAllWifi = {};
        data.data.scan_result.forEach(function(info) {
          that.listofAllWifi[info.ssid] = info;
        });
        console.log(that.listofAllWifi);
        delay.resolve(data);
      }, function(err) {
        delay.reject(err);
      });
      return delay.promise;
    };

    this.getSettings = function() {
      this.intervalKey = $interval(function() {
        if(that.userSettings.wifiSwitchOn && that.wirelessError === false) {
          $http.get(host + ':8000/network/wlan')
          .then(function(result) {
            that.processData(result);
          }, function(err) {
            that.processOnError(err); // in case error ,May be no wireless interface
          });
        }
      }, 3000);
    };

    this.processData = function(result) {

      this.wirelessError = false;
      if(result.data.settings) {
        this.connectedWifiNetwork = result.data;
        var _ssid = result.data.settings["wpa-ssid"];
        var _connectionStatus = result.data.state.status;
        if(ssid !== _ssid || this.connectionStatus !== _connectionStatus) {
          ssid = _ssid;
          this.connectionStatus = _connectionStatus;
          $rootScope.$broadcast("new_wifi_result");
        }
      }

    };

    this.processOnError = function(err) {

      ssid = this.connectionStatus = null;
      this.connectedWifiNetwork = {};
      this.wirelessError = true;
      this.wirelessErrorData = err.data.status;
      $rootScope.$broadcast("wifi_adapter_error");
    };

    this.getInitialStatus = function() {

      var delay = $q.defer();
      $http.get(host + ':8000/network/wlan')
      .then(function(result) {
        delay.resolve(result);
      }, function(err) {
        delay.reject(err);
      });
      return delay.promise;
    };

    this.getEtherNetStatus = function() {

      var delay = $q.defer();
      $http.get(host + ':8000/network/eth0')
      .then(function(ethernet) {
        that.connectedEthernet = ethernet.data;
        $rootScope.$broadcast("ethernet_detected");
      });
    };

    this.connectWifi = function(data) {

      var delay = $q.defer();
      $http.put(host + ':8000/network/wlan', data)
      .then(function(result) {
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
        that.connectionStatus = ssid = null;
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
        $.jStorage.set('userNetworkSettings', that.userSettings);
        $rootScope.$broadcast("wifi_restarted");
        delay.resolve(result);
      }, function(err) {
        delay.reject(err);
      });

      return delay.promise;
    };

    //Taking a note on network status so that user see the result as soon as
    //user comes to /settings/networkmanagement
    var initialStatus = this.getInitialStatus();

    initialStatus.then(function() {
      console.log("Network is fine .. !");
    }, function(err) {
      console.log("No Wifi Interface .. !");
      that.processOnError(err);
    });

    //We need to make sure that, we call /network api only when we are in
    // /settings/networkmanagement
    $rootScope.$on("$stateChangeStart", function(event, toState) {
        // If we are not in the network settings part, we dont have to query /network anymore
        if(toState.name !== "settings.networkmanagement" && toState.name !== "settings.networkmanagement.wifi") {
          $interval.cancel(that.intervalKey);
        }
    });
  }
]);
