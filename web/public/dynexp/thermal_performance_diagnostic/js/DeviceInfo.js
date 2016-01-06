(function() {

  App.service('DeviceInfo', [
    '$http',
    '$q',
    function($http, $q) {

      this.getInfo = function() {
        var deferred = $q.defer();
        $http.get('/device/status').then(function(data) {
          deferred.resolve(data);
        }, function(err) {
          deferred.reject(err);
        });
        return deferred.promise;
      };

    }

  ]);

})();
