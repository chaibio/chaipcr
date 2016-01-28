(function() {
  angular.module('status.service', [
    'global.service'
  ])
  .service('Status', [
    '$http', '$q', '$interval', '$timeout', '$rootScope', 'GlobalService',
    function ($http, $q, $interval, $timeout, $rootScope, GlobalService) {
      var host = GlobalService.baseUrl;
      var data, fetchInterval, fetching, isUp, ques, timeoutPromise;
      data = null;
      isUp = true;
      fetchInterval = null;
      this.listenersCount = 0;
      fetching = false;
      timeoutPromise = null;
      ques = [];
      this.getData = function() {
        return data;
      };
      this.isUp = function() {
        return isUp;
      };
      this.fetch = function() {
        var deferred;
        deferred = $q.defer();
        ques.push(deferred);
        if (fetching) {
          return deferred.promise;
        }
        fetching = true;
        timeoutPromise = $timeout((function(_this) {
          return function() {
            timeoutPromise = null;
            return fetching = false;
          };
        })(this), 10000);
        $http.get(host + "\:8000/status").success((function(_this) {
          return function(resp) {
            var def, i, len, oldData;
            isUp = true;
            oldData = angular.copy(data);
            data = resp;
            for (i = 0, len = ques.length; i < len; i += 1) {
              def = ques[i];
              def.resolve(data);
            }
            return $rootScope.$broadcast('status:data:updated', data, oldData);
          };
        })(this)).error(function(resp) {
          var def, i, len, results;
          isUp = resp === null ? false : true;
          results = [];
          for (i = 0, len = ques.length; i < len; i += 1) {
            def = ques[i];
            results.push(def.reject(resp));
          }
          return results;
        })["finally"]((function(_this) {
          return function() {
            $timeout.cancel(timeoutPromise);
            timeoutPromise = null;
            fetching = false;
            return ques = [];
          };
        })(this));
        return deferred.promise;
      };
      this.startSync = function() {
        if (!fetching) {
          this.fetch();
        }
        if (!fetchInterval) {
          return fetchInterval = $interval(this.fetch, 1000);
        }
      };
    }
  ]);

}).call(this);
