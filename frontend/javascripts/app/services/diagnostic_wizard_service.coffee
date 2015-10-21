window.ChaiBioTech.ngApp.service 'DiagnosticWizardService', [
  ->
    @temperatureLogs = (temperature_logs) ->
      getLidTemps: ->
        # if temperature_logs.length > 100
        #   new_temp_logs = []
        #   offset = 20
        #   for datum, i in temperature_logs by 1
        #     max_index = temperature_logs.length-1
        #     chunk = temperature_logs.slice (if i <= offset then 0 else i-offset), (if i >= max_index-offset then max_index-i else i+offset)
        #     if chunk.length > 0
        #       average = 0
        #       for c in chunk by 1
        #         average += parseFloat(c.temperature_log.lid_temp)

        #       new_temp_logs.push
        #         x: datum.temperature_log.elapsed_time
        #         y: average/chunk.length

        #   new_temp_logs

        # else
        _.map temperature_logs, (datum) ->
          x: datum.temperature_log.elapsed_time
          y: parseFloat(datum.temperature_log.lid_temp)
      getBlockTemps: ->
        _.map temperature_logs, (datum) ->
          x: datum.temperature_log.elapsed_time
          y: (parseFloat(datum.temperature_log.heat_block_zone_1_temp) + parseFloat(datum.temperature_log.heat_block_zone_2_temp))/2

    return
]