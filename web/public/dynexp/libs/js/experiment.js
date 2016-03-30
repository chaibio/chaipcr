(function() {

  var App = angular.module('experiment.service', ['global.service']);

  App.service('Experiment', [
    '$http',
    'GlobalService',
    '$q',
    function($http, GlobalService, $q) {
      var currentExperiment, self;
      currentExperiment = null;
      var host = GlobalService.baseUrl;
      var ques = {};

      self = this;

      self.setCurrentExperiment = function(exp) {
        return currentExperiment = exp;
      };
      self.getCurrentExperiment = function() {
        return currentExperiment;
      };
      self.getTemperatureData = function(expId, opts) {
        if (opts == null) {
          opts = {};
        }
        opts.starttime = opts.starttime || 0;
        opts.resolution = opts.resolution || 1000;
        return $http.get("/experiments/" + expId + "/temperature_data", {
          params: {
            starttime: opts.starttime,
            endtime: opts.endtime,
            resolution: opts.resolution
          }
        });
      };
      self.get = function(id) {
        var deferred = $q.defer();
        ques['exp_'+id] = ques['exp_'+id] || [];
        ques['exp_'+id].push(deferred);

        if (ques['exp_'+id].length === 1)
          $http.get('/experiments/' + id)
          .then(function (resp) {
            for (var i = ques['exp_'+id].length - 1; i >= 0; i--) {
              var deferred = ques['exp_'+id][i];
              deferred.resolve(resp);
            }
          })
          .catch(function (resp) {
            for (var i = ques['exp_'+id].length - 1; i >= 0; i--) {
              var deferred = ques['exp_'+id][i];
              deferred.reject(resp);
            }
          })
          .finally(function () {
            delete ques['exp_'+id];
          });

        return deferred.promise;
      }
      self.getFluorescenceData = function(expId) {
        return $http.get("/experiments/" + expId + "/amplification_data");
      };
      self.create = function(exp) {
        return $http.post("/experiments", {
          experiment: exp
        });
      };
      self.duplicate = function(expId, data) {
        return $http.post("/experiments/" + expId + "/copy", data);
      };
      self.startExperiment = function(expId) {
        return $http.post(host + ":8000/control/start", {
          experiment_id: expId
        });
      };
      self.resumeExperiment = function() {
        return $http.post(host + ":8000/control/resume");
      };
      self.stopExperiment = function() {
        return $http.post(host + ":8000/control/stop");
      };
      self.analyze = function(id) {
        return $http.get("/experiments/" + id + "/analyze");
      };

      self.getStepsData = function(exp_id, step_ids) {
        var q = '';
        for (var i = 0; i < step_ids.length; i++) {
          if (i > 0) q = q + '&';
          q = q + 'step_id[]=' + step_ids[i];
        }
        return $http.get('/experiments/' + exp_id + '/amplification_data?' + q);
      }

      self.getTemperatureData = function(expId, opts) {
        if (opts == null) {
          opts = {};
        }
        opts.starttime = opts.starttime || 0;
        opts.resolution = opts.resolution || 1000;
        return $http.get("/experiments/" + expId + "/temperature_data", {
          params: {
            starttime: opts.starttime,
            endtime: opts.endtime,
            resolution: opts.resolution
          }
        });
      };


      return self;
    }
  ]);

})();
