window.ChaiBioTech.ngApp.service('NetworkSettingsService',[
  '$http',
  '$q',
  'host',
  function($http, $q, host) {

    this.getWifiNetworks = function() {
      console.log(host);
      $http.get(host + ':8000/network/wlan0/scan').then(function(data) {
        console.log(data);
      });
    };
  }
]);
