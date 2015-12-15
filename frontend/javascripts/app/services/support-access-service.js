window.ChaiBioTech.ngApp.service('supportAccessService', [
  '$q',
  '$http',
  function($q, $http) {

    this.accessSupport = function() {

      var delay = $q.defer();
      var url = '/device/enable_support_access';

      $http.post(url, {})
      .success(function(data) {
        delay.resolve(data);
      })
      .error(function(data) {
        delay.reject(data);
      });

      return delay.promise;
    };
  }
]);
