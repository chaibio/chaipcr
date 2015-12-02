
  App.service('Status', [
    '$http', '$q', 'host', '$interval', '$timeout',
    function ($http, $q, host, $interval, $timeout) {
      var data;
      var self = this;
      data = null;
      self.interval = null;
      self.listenersCount = 0;
      self.fetching = false;
      self.timeoutPromise = null;
      self.getData = function() {
        return data;
      };
      self.fetch = function() {
        var deferred;
        deferred = $q.defer();
        if (!self.fetching) {
          self.fetching = true;
          self.timeoutPromise = $timeout((function(_self) {
            return function() {
              _self.fetching = false;
              return _self.timeoutPromise = null;
            };
          })(self), 10000);
          $http.get(host + "\:8000/status").success((function(_self) {
            return function(resp) {
              data = resp;
              return deferred.resolve(data);
            };
          })(self)).error(function(resp) {
            return deferred.reject(resp);
          })["finally"]((function(_self) {
            return function() {
              $timeout.cancel(_self.timeoutPromise);
              _self.timeoutPromise = null;
              return _self.fetching = false;
            };
          })(self));
        } else {
          deferred.resolve(data);
        }
        return deferred.promise;
      };
      self.startSync = function() {
        self.listenersCount += 1;
        if (!self.fetching) {
          self.fetch();
        }
        if (!self.interval) {
          return self.interval = $interval(self.fetch, 3000);
        }
      };
      self.stopSync = function() {
        self.listenersCount -= 1;
        if (self.listenersCount === 0) {
          $interval.cancel(self.interval);
          return self.interval = null;
        }
      };
    }
  ]);