angular.module('dynexp.libs')
  .service('dynexpDeviceInfo', [
    '$http',
    '$q',
    'host',
    function($http, $q, host) {

      this.getInfo = function(no) {
        var deferred = $q.defer();
        $http.get("http://" + window.location.hostname + ":8000/status").then(function(data) {
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
