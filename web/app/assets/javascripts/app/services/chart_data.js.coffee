
# this file formats data from different sources to be consumed by various chart libraries

window.ChaiBioTech.ngApp

.factory 'ChartData', [
  ->
    temperatureLogs:
      # formats temperature logs for angular-charts
      toAngularCharts: (temperature_logs) ->

        data = _.pluck temperature_logs, 'temperature_log'

        elapsed_time = _.map (_.pluck data, 'elapsed_time'), (et) ->
          time = parseInt(et)
          moment().startOf('day').add(time, 'seconds').format('HH:mm:ss')

        heat_block_zone_1_temp = _.map (_.pluck data, 'heat_block_zone_1_temp'), (hb1) ->
          parseFloat(hb1)

        heat_block_zone_2_temp = _.map (_.pluck data, 'heat_block_zone_2_temp'), (hb2) ->
          parseFloat(hb2)

        lid_temp = _.map (_.pluck data, 'lid_temp'), (lt) ->
          parseFloat(lt)

        elapsed_time: elapsed_time
        heat_block_zone_1_temp: heat_block_zone_1_temp
        heat_block_zone_2_temp: heat_block_zone_2_temp
        lid_temp: lid_temp



]