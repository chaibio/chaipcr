(function() {
  angular.module('dynexp.libs')
  .service('dynexpGlobalService', [
    '$http',
    function GlobalService($http) {

      var self = this;
      var holding = false;
      var max_delta_tm_cache = null;

      self.isDualChannel = function (cb) {
        $http.get('/capabilities')
        .then(function (resp) {
          var it_is = resp.data.capabilities.optics.emission_channels.length === 2;
          cb(it_is);
        })
        .catch(function () {
          cb(false);
        });
      };

      self.baseUrl = "http://" + window.location.hostname;

      self.isHolding = function(data, experiment) {
        var duration, stages, state, steps;
        if (!experiment) {
          return false;
        }
        if (!experiment.protocol) {
          return false;
        }
        if (!experiment.protocol.stages) {
          return false;
        }
        if (!data) {
          return false;
        }
        if (!data.experiment_controller) {
          return false;
        }
        stages = experiment.protocol.stages;
        steps = stages[stages.length - 1].stage.steps;
        duration = parseInt(steps[steps.length - 1].step.delta_duration_s);
        state = data.experiment_controller.machine.state;
        holding = state === 'complete' && duration === 0;
        return holding;
      };
      self.timeRemaining = function(data) {
        var exp, time;
        if (!data) {
          return 0;
        }
        if (!data.experiment_controller) {
          return 0;
        }
        if (data.experiment_controller.machine.state !== 'idle') {
          exp = data.experiment_controller.experiment;
          time = ((exp.estimated_duration*1) + (exp.paused_duration*1)) - (exp.run_duration*1);
          return time < 0 ? 0 : time;
        } else {
          return 0;
        }
      };
      this.getExperimentSteps = function(exp) {
        var stages = exp.protocol.stages;
        var steps = [];

        for (var i = 0; i < stages.length; i++) {
          var stage = stages[i].stage;
          var _steps = stage.steps;

          for (var ii = 0; ii < _steps.length; ii++) {
            steps.push(_steps[ii].step);
          }
        }
        return steps;
      };

      this.getMaxDeltaTm = function(tms) {
        if (max_delta_tm_cache !== null) return max_delta_tm_cache;
        var min_tm = Math.min.apply(Math, tms);
        var max_tm = Math.max.apply(Math, tms);
        max_delta_tm_cache = max_tm - min_tm;
        return max_delta_tm_cache;
      };


      this.getTmValues = function(analyze_data) {
        var tms = [];
        for (var i = 0; i < 16; i++) {
          tms.push(analyze_data.tm_check[i].Tm);
        }
        return tms;
      };

    }
  ]);
}).call(window);
