
  App.service('DiagnosticWizardService', [
    function() {
      this.temperatureLogs = function(temperature_logs) {

        var last_elapsed_time_in_sec;
        var temperature_logs_cp = angular.copy(temperature_logs);
        last_elapsed_time_in_sec = temperature_logs_cp[temperature_logs_cp.length - 1].temperature_log.elapsed_time / 1000;
        if (last_elapsed_time_in_sec > 30) {
          temperature_logs_cp = _.select(temperature_logs_cp, function(datum) {
            return datum.temperature_log.elapsed_time / 1000 > last_elapsed_time_in_sec - 30;
          });
        }
        temperature_logs_cp = _.map(temperature_logs_cp, function(datum) {
          var datumCp;
          datumCp = datum;
          datumCp.temperature_log.elapsed_time = datum.temperature_log.elapsed_time - (last_elapsed_time_in_sec - 30) * 1000;
          return datumCp;
        });

        return {
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
          }
        };
      };
    }
  ]);