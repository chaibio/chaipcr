(function() {

  App.service('DeviceInfo', [
    '$http',
    '$q',
    function($http, $q) {

      this.getInfo = function(no) {
        var deferred = $q.defer();
        $http.get('/device/status').then(function(data) {
          /*data.data.optics.lid_open = "true";
          if(no > 15 && no < 30) {
            data.data.optics.lid_open = "false";
          }*/
          deferred.resolve(data);
        }, function(err) {
          deferred.reject(err);
        });
        return deferred.promise;
      };

    }

  ]);

})();
