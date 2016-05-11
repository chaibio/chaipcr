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
      //console.log(Webworker);
      var delay = $q.defer();
      var ssid = null, connectionStatus = null;

      $interval(function() {
        $http.get(host + ':8000/network/wlan').then(function(result) {

          if(result.data.settings) {

            if(ssid === null && connectionStatus === null) {
              ssid = result.data.settings["wpa-ssid"];
              connectionStatus = result.data.state.status;
              that.connectedWifiNetwork = result.data;
              $rootScope.$broadcast("new_wifi_result");
              return;
            }
            if(ssid !== result.data.settings["wpa-ssid"] || connectionStatus !== result.data.state.status) {
              ssid = result.data.settings["wpa-ssid"];
              connectionStatus = result.data.state.status;
              that.connectedWifiNetwork = result.data;
              $rootScope.$broadcast("new_wifi_result");
            }
          }
        }, function(err) {
          // in case error
        });
      }, 3000);
      return delay.promise;
    };

    //this.getSettings();

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
