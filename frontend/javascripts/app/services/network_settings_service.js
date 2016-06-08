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
    var that = this;
    this.connectedWifiNetwork = {};
    this.connectedEthernet = {};
    this.wirelessError = false;
    this.wirelessErrorData = {};
    this.connectionStatus = "";

    this.getWifiNetworks = function() {
      var delay = $q.defer();
      $http.get(host + ':8000/network/wlan/scan').then(function(data) {
        delay.resolve(data);
      }, function(err) {
        delay.reject(err);
      });
      return delay.promise;
    };

    this.getSettings = function() {
      //var delay = $q.defer();
      var ssid = null, connectionStatus = null;

      $interval(function() {
        $http.get(host + ':8000/network/wlan').then(function(result) {

          that.wirelessError = false;
          if(result.data.settings) {

            if(ssid === null && connectionStatus === null) {
              ssid = result.data.settings["wpa-ssid"];
              that.connectionStatus = connectionStatus = result.data.state.status;
              that.connectedWifiNetwork = result.data;
              $rootScope.$broadcast("new_wifi_result");
              return;
            }
            if(ssid !== result.data.settings["wpa-ssid"] || connectionStatus !== result.data.state.status) {
              ssid = result.data.settings["wpa-ssid"];
              that.connectionStatus = connectionStatus = result.data.state.status;
              that.connectedWifiNetwork = result.data;
              $rootScope.$broadcast("new_wifi_result");
            }
          }
        }, function(err) {
          // in case error May be no wireless interface
          that.wirelessError = true;
          that.wirelessErrorData = err.data.status;
          $rootScope.$broadcast("wifi_adapter_error");
        });
      }, 3000);
      //return delay.promise;
    };

    getInitialStatus = function() {
      var delay = $q.defer();
      $http.get(host + ':8000/network/wlan').then(function(result) {
        delay.resolve(result);
      }, function(err) {
        delay.reject(err);
      });
      return delay.promise;
    };

    this.getEtherNetStatus = function() {
        var delay = $q.defer();
        $http.get(host + ':8000/network/eth0').then(function(ethernet) {
          that.connectedEthernet = ethernet.data;
          $rootScope.$broadcast("ethernet_detected");
        });
    };

    this.connectWifi = function(data) {
      var delay = $q.defer();
      $http.put(host + ':8000/network/wlan', data).then(function(result) {
        delay.resolve(result);
      }, function(err) {
        delay.reject(err);
      });

      return delay.promise;
    };
  }
]);
