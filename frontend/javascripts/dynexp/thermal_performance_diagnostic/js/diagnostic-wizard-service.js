angular.module('dynexp.thermal_performance_diagnostic')
  .service('DiagnosticWizardService', [
    function() {
      this.temperatureLogs = function(temperature_logs) {

        var temperature_logs_cp = angular.copy(temperature_logs);

        return {
          getLast30seconds: function() {
            var last_elapsed_time_in_sec;
            last_elapsed_time_in_sec = temperature_logs_cp[temperature_logs_cp.length - 1].temperature_log.elapsed_time / 1000;
            if (last_elapsed_time_in_sec > 30) {
              temperature_logs_cp = _.select(temperature_logs_cp, function(datum) {
                return datum.temperature_log.elapsed_time / 1000 > last_elapsed_time_in_sec - 30;
              });
            }
            return temperature_logs_cp;
          },
          getLidTemps: function() {
            return _.map(temperature_logs_cp, function(datum) {
              return {
                x: datum.temperature_log.elapsed_time,
                y: parseFloat(datum.temperature_log.lid_temp)
              };
            });
          },
          getBlockTemps: function() {
            return _.map(temperature_logs_cp, function(datum) {
              return {
                x: datum.temperature_log.elapsed_time,
                y: (parseFloat(datum.temperature_log.heat_block_zone_1_temp) + parseFloat(datum.temperature_log.heat_block_zone_2_temp)) / 2
              };
            });
          },

          getMaxAttr: function(attr) {
            var ys = _.map(temperature_logs_cp, function(datum) {
              return parseFloat(datum.temperature_log[attr]);
            });
            return Math.max.apply(Math, ys);
          },

          getMinAttr: function(attr) {
            var ys = _.map(temperature_logs_cp, function(datum) {
              return parseFloat(datum.temperature_log[attr]);
            });
            return Math.min.apply(Math, ys);
          }

        };
      };
    }
  ]);
