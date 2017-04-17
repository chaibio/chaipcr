(function() {
  angular.module('dynexp.libs')
  .service('dynexpStatusService', [
    '$http', '$q', '$interval', '$timeout', '$rootScope', 'dynexpGlobalService',
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
            fetching = false;
          };
        })(this), 10000);
        $http.get(host + "\:8000/status").then((function(_this) {
          return function(resp) {
            var def, i, len, oldData;
            isUp = true;
            oldData = angular.copy(data);
            data = resp.data;
            for (i = 0, len = ques.length; i < len; i += 1) {
              def = ques[i];
              def.resolve(data);
            }
            $rootScope.$broadcast('status:data:updated', data, oldData);
          };
        })(this)).catch(function(resp) {
          var def, i, len, results;
          isUp = resp.status === 0 ? false : true;
          results = [];
          for (i = 0, len = ques.length; i < len; i += 1) {
            def = ques[i];
            results.push(def.reject(resp));
          }
          $rootScope.$broadcast('status:data:error', resp);
        })["finally"]((function(_this) {
          return function() {
            $timeout.cancel(timeoutPromise);
            timeoutPromise = null;
            fetching = false;
            ques = [];
          };
        })(this));
        return deferred.promise;
      };
      this.startSync = function() {
        if (!fetching) {
          this.fetch();
        }
        if (!fetchInterval) {
          fetchInterval = $interval(this.fetch, 1000);
        }
      };
      this.stopSync = function () {
        $interval.cancel(fetchInterval);
      };
    }
  ]);

}).call(window);
