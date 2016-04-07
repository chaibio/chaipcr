App.service 'MeltCurveService', [
  'AmplificationChartHelper'
  'Webworker'
  (AmplificationChartHelper, Webworker) ->
    self = @

    self.defaultData = ->
      datasets = {}
      for i in [0..15] by 1
        datasets["well_#{i}"] = []
      return datasets

    self.chartConfig = (type) ->
      series = []
      # for i in [0..1] by 1
      for i in [0..15] by 1
        series.push
          axis: 'y'
          key: type
          dataset: "well_#{i}"
          color: AmplificationChartHelper.COLORS[i]
          type: 'line'
          id: "well_#{i}"
          label: "well_#{i+1}: "

      axes:
        x:
          key: 'temperature'
          ticks: 8
          tickFormat: (x) ->
            return "#{x}°C"
        y:
          ticks: 10
      margin:
        left: 70
        right: 0

      grid:
        x: false
        y: false

      series: series

      tooltipHook: (items) ->
        rows = []
        for item in items by 1
          rows.push
            label: item.series.label
            value: "#{item.row.y1.toFixed(2)}"
            id: item.series.id
            color: item.series.color

        abscissas: "#{item.row.x.toFixed(2)} °C"
        rows: rows
    # end chartConfig

    self.XTicks = (min, max) ->
      ticks = []
      calib = 10
      diff = max - min
      if diff <= calib
        for i in [min..max] by 1
          ticks.push i
        return ticks
      else
        return calib
    # end ticks

    parseData = (data) ->
      datasets = {}

      for well, i in data by 1
        datasets["well_#{i}"] = []

        for temp, ii in data[i].temperature by 1

          total_temp = 0
          for t in [0..15] by 1
            total_temp += data[t].temperature[ii]

          datasets["well_#{i}"].push
            temperature: total_temp/16
            derivative: data[i].derivative[ii]
            normalized: data[i].fluorescence_data[ii]

      complete(datasets)

    self.parseData = (data, cb) ->
      parser = Webworker.create(parseData, async:true);
      return parser.run(data)
    # end parseData

    self.optimizeForEachResolution = (data, range) ->
      worker = (data, range, angular) ->
        mc_data = angular.copy(data)
        new_data = self.optimizeForResolution(data, range, angular)
        console.log new_data
        complete(new_data)
      #   new_data = [angular.copy(data)]
      #   for r in [range-2..0] by -1
      #     new_data.push(self.optimizeForResolution(data, r, range, angular))
      #   complete(new_data)

      return Webworker.create(worker, async:true).run(data, range, angular)


    self.optimizeForResolution = (data, resolution, range, angular) ->
      mc_data = angular.copy data
      calibration_dp = 800
      data_length = data[0].temperature.length
      chunkSize = Math.round((data_length*(resolution / range)) / calibration_dp)
      chunkSize = if chunkSize > 0 then chunkSize else 1

      return _.map mc_data, (well_data) ->
        chunked = _.chunk well_data, chunkSize
        averaged_data = _.map chunked, (chunk) ->
          total_temperature = 0
          total_derivative = 0
          total_normalized = 0

          for c in chunk by 1
            total_temperature += c.temperature
            total_derivative += c.derivative
            total_normalized += c.normalized

          return {
            temperature: total_elapsed_time/chunk.length
            derivative: total_derivative/chunk.length
            normalized: total_normalized/chunk.length
          }

        averaged_data.unshift well_data[0]
        averaged_data.push well_data[well_data.length-1]

    self.getTempRange = (data) ->
      temps = []
      for d in data[0].temperature by 1
        temps.push d

      min_temp = Math.min.apply(Math, temps)
      max_temp = Math.max.apply(Math, temps)

      return {min: min_temp, max: max_temp}
    # end getTempRange

    return self

]