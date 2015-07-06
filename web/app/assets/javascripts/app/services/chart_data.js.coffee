
# this file formats data from different sources to be consumed by various chart libraries

window.ChaiBioTech.ngApp

.service 'ChartData', [
  'SecondsDisplay'
  (SecondsDisplay) ->

    @temperatureLogs = (temperature_logs) ->
      # formats temperature logs for angular-charts
      toAngularCharts: ->

        elapsed_time = []
        heat_block_zone_temp = []
        lid_temp = []

        for temp_log in angular.copy(temperature_logs)
          elapsed_time.push SecondsDisplay.display2 Math.round(temp_log.temperature_log.elapsed_time/1000)

          # get heat_block_zone_temp average
          hbz = (parseFloat(temp_log.temperature_log.heat_block_zone_1_temp)+ parseFloat(temp_log.temperature_log.heat_block_zone_2_temp))/2
          # round to nearest hundreth
          hbz = Math.ceil(hbz*100)/100

          heat_block_zone_temp.push hbz
          lid_temp.push parseFloat temp_log.temperature_log.lid_temp

        elapsed_time: elapsed_time
        heat_block_zone_temp: heat_block_zone_temp
        lid_temp: lid_temp

      toNVD3: ->
        lid_temps = []
        heat_block_zone_temps = []

        for temp_log in angular.copy(temperature_logs)
          et = temp_log.temperature_log.elapsed_time

          lid_temps.push [
            et
            parseFloat temp_log.temperature_log.lid_temp
          ]

          hbzAverage = (parseFloat temp_log.temperature_log.heat_block_zone_1_temp + parseFloat temp_log.temperature_log.heat_block_zone_2_temp ) / 2

          heat_block_zone_temps.push [
            et
            Math.round(hbzAverage*100)/100 #round to hundreth
          ]

        lid_temps: lid_temps
        heat_block_zone_temps: heat_block_zone_temps

    return

]