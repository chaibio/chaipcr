(function () {
  var app = angular.module('global.service', []);
  app.service('GlobalService', [
    '$http',
    function GlobalService ($http) {

      var self = this;
      var holding = false;

      self.baseUrl = "http://" + window.location.hostname;

      self.getExperiment = function (id) {
        return $http.get(self.baseUrl+"/experiments/"+id);
      };

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
        if (data.experiment_controller.machine.state === 'running') {
          exp = data.experiment_controller.expriment;
          time = (exp.estimated_duration * 1 + exp.paused_duration * 1) - exp.run_duration * 1;
          if (time < 0) {
            time = 0;
          }
          return time;
        } else {
          return 0;
        }
      };

    }
  ]);
}).call(window);