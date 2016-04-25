window.ChaiBioTech.ngApp.service('NetworkSettingsService',[
  '$http',
  '$q',
  'host',
  function($http, $q, host) {

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
      var delay = $q.defer();
      $http.get(host + ':8000/network/wlan').then(function(data) {
        delay.resolve(data);
      }, function(err) {
        delay.reject(err);
      });

      return delay.promise;
    };
  }
]);
